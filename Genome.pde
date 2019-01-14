class Genome {
  ArrayList<connectionGene> genes = new  ArrayList<connectionGene>();//lista de conexiones entre nodos, que representa la red neuronal
  ArrayList<Node> nodes = new ArrayList<Node>();//lista de nodos
  int inputs;
  int outputs;
  int layers =2;
  int nextNode = 0;
  int biasNode;

  ArrayList<Node> network = new ArrayList<Node>();//lista de nodos en el orden que se tiene que considerar en la red neuronal
  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Genome(int in, int out) {
    //entradas y salidas
    inputs = in;
    outputs = out;

    //nodos de entrada
    for (int i = 0; i<inputs; i++) {
      nodes.add(new Node(i));
      nextNode ++;
      nodes.get(i).layer =0;
    }

    //nodos de salida
    for (int i = 0; i < outputs; i++) {
      nodes.add(new Node(i+inputs));
      nodes.get(i+inputs).layer = 1;
      nextNode++;
    }

    nodes.add(new Node(nextNode));//nodo sigueinte
    biasNode = nextNode; 
    nextNode++;
    nodes.get(biasNode).layer = 0;
  }



  //devuelve el nodo con el numero indicado, los nodos pueden no estar en orden
  Node getNode(int nodeNumber) {
    for (int i = 0; i < nodes.size(); i++) {
      if (nodes.get(i).number == nodeNumber) {
        return nodes.get(i);
      }
    }
    return null;
  }


  //añade la conexion hacia el siguiente nodo para poder acceder a el
  void connectNodes() {

    for (int i = 0; i< nodes.size(); i++) {//limpiar las conexiones
      nodes.get(i).outputConnections.clear();
    }

    for (int i = 0; i < genes.size(); i++) {//para connectionGene
      genes.get(i).fromNode.outputConnections.add(genes.get(i));//añadirlo al nodo
    }
  }

  //llenando los valores de entrada en la red neuronal y devolver el array de salida
  float[] feedForward(float[] inputValues) {
    //poner las salidas[outputs] como las entradas[inputs]
    for (int i =0; i < inputs; i++) {
      nodes.get(i).outputValue = inputValues[i];
    }
    nodes.get(biasNode).outputValue = 1;//la salida del siguiente es 1

    for (int i = 0; i< network.size(); i++) {//conectar cada nodo
      network.get(i).engage();
    }

    //poner las salidas[inputs] como las entradas[inputs+outputs-1]
    float[] outs = new float[outputs];
    for (int i = 0; i < outputs; i++) {
      outs[i] = nodes.get(inputs + i).outputValue;
    }

    for (int i = 0; i < nodes.size(); i++) {//reiniciar nodos para el siguiente avance
      nodes.get(i).inputSum = 0;
    }

    return outs;
  }

  //generar la red neuronal como una lista de nodos para conectar 
  void generateNetwork() {
    connectNodes();
    network = new ArrayList<Node>();
    //para cada capa añadir un nodo, las capas no puedes conectarse entre ellas, no hay necesidad de ordenar los nodos en una capa

    for (int l = 0; l< layers; l++) {//para cada capa
      for (int i = 0; i< nodes.size(); i++) {//para cada nodo
        if (nodes.get(i).layer == l) {//si el nodo ya esta en la capa
          network.add(nodes.get(i));
        }
      }
    }
  }
  //mutar la red neuronal añadiendo un nuevo nodo
  //se selecciona un nodo aleatorio y se desactiva, entonces se añaden 2 conexiones
  //1 entre en nodo de entrada de la conexion desactivada y el nuevo nodo
  //y otro entre el nuevo nodo y la salida de la conexion desactivada
  void addNode(ArrayList<connectionHistory> innovationHistory) {
    //escoger nodo aleatorio para añadir un nuevo nodo
    if (genes.size() ==0) {
      addConnection(innovationHistory); 
      return;
    }
    int randomConnection = floor(random(genes.size()));

    while (genes.get(randomConnection).fromNode == nodes.get(biasNode) && genes.size() !=1 ) {//no desconectar el bias
      randomConnection = floor(random(genes.size()));
    }

    genes.get(randomConnection).enabled = false;//desactivarlo

    int newNodeNo = nextNode;
    nodes.add(new Node(newNodeNo));
    nextNode ++;
    //añadir una nueva conexion a un nodo de valor 1
    int connectionInnovationNumber = getInnovationNumber(innovationHistory, genes.get(randomConnection).fromNode, getNode(newNodeNo));
    genes.add(new connectionGene(genes.get(randomConnection).fromNode, getNode(newNodeNo), 1, connectionInnovationNumber));


    connectionInnovationNumber = getInnovationNumber(innovationHistory, getNode(newNodeNo), genes.get(randomConnection).toNode);
    //añadir una nueva conexion desde el nuevo nodo con el mismo valor que la conexion desactivada
    genes.add(new connectionGene(getNode(newNodeNo), genes.get(randomConnection).toNode, genes.get(randomConnection).weight, connectionInnovationNumber));
    getNode(newNodeNo).layer = genes.get(randomConnection).fromNode.layer +1;


    connectionInnovationNumber = getInnovationNumber(innovationHistory, nodes.get(biasNode), getNode(newNodeNo));
    //conectar bias el nuevo nodo con valor 0
    genes.add(new connectionGene(nodes.get(biasNode), getNode(newNodeNo), 0, connectionInnovationNumber));

    //si la capa del nuevo nodo es igual a la capa del nodo de salida de la vieja conexion, se crea una nueva capa
    //si el numero de capas es igual o mayor que el numero del nuevo nodo, se incrementa el valor del nuevo nodo
    if (getNode(newNodeNo).layer == genes.get(randomConnection).toNode.layer) {
      for (int i = 0; i< nodes.size() -1; i++) {//no incluir el nodo mas nuevo
        if (nodes.get(i).layer >= getNode(newNodeNo).layer) {
          nodes.get(i).layer ++;
        }
      }
      layers ++;
    }
    connectNodes();
  }

  //conecta 2 nodos que no estan actualmente conectados
  void addConnection(ArrayList<connectionHistory> innovationHistory) {
    //no se puede añadir una conexion a una red completamente conectada
    if (fullyConnected()) {
      println("connection failed");
      return;
    }


    //obtener nodos aleatorios
    int randomNode1 = floor(random(nodes.size())); 
    int randomNode2 = floor(random(nodes.size()));
    while (randomConnectionNodesAreBad(randomNode1, randomNode2)) {//si los nodos no son buenos, repetir
      randomNode1 = floor(random(nodes.size())); 
      randomNode2 = floor(random(nodes.size()));
    }
    int temp;
    if (nodes.get(randomNode1).layer > nodes.get(randomNode2).layer) {//si el primer nodo va despues del segundo, intercambiarlos
      temp =randomNode2  ;
      randomNode2 = randomNode1;
      randomNode1 = temp;
    }    

    //obtener el numero de imnovacion de la conexion
    //nuevo numero en caso si 2 genome, diferentes, han mutado de la misma manera 
    int connectionInnovationNumber = getInnovationNumber(innovationHistory, nodes.get(randomNode1), nodes.get(randomNode2));
    //añadir conexion con un array aleatorio

    genes.add(new connectionGene(nodes.get(randomNode1), nodes.get(randomNode2), random(-1, 1), connectionInnovationNumber));//changed this so if error here
    connectNodes();
  }
  //-------------------------------------------------------------------------------------------------------------------------------------------
  //Comprobar que los 2 nodos escogidos son compatibles, es decir, no pertenecen a la misma capa ni estan completamente conectados
  boolean randomConnectionNodesAreBad(int r1, int r2) {
    if (nodes.get(r1).layer == nodes.get(r2).layer) return true; //si el nodo esta en la misma capa
    if (nodes.get(r1).isConnectedTo(nodes.get(r2))) return true; //si estan ya conectados
    return false;
  }
  //devuelve el numero de innovacion de la nueva mutacion
  //si es nueva, recibira un nuevo numero
  //si ya se habia visto, se le vuelve a dar dicho numero
  
  int getInnovationNumber(ArrayList<connectionHistory> innovationHistory, Node from, Node to) {
    boolean isNew = true;
    int connectionInnovationNumber = nextConnectionNo;
    for (int i = 0; i < innovationHistory.size(); i++) {//para cada mutacion previa
      if (innovationHistory.get(i).matches(this, from, to)) {//si se encuentra una igual
        isNew = false;
        connectionInnovationNumber = innovationHistory.get(i).innovationNumber; //darle el valor de la innovacion como la ya mutada
        break;
      }
    }

    if (isNew) {//en caso de que sea nueva, crear un arraylist de int representando el valor actual del genoma
      ArrayList<Integer> innoNumbers = new ArrayList<Integer>();
      for (int i = 0; i< genes.size(); i++) {//dar los valores de imnovacion
        innoNumbers.add(genes.get(i).innovationNo);
      }

      //añadirla a "innovationHistory" 
      innovationHistory.add(new connectionHistory(from.number, to.number, connectionInnovationNumber, innoNumbers));
      nextConnectionNo++;
    }
    return connectionInnovationNumber;
  }
  //----------------------------------------------------------------------------------------------------------------------------------------

  //nos dice si la red esta enteramente conectada o no
  boolean fullyConnected() {
    int maxConnections = 0;
    int[] nodesInLayers = new int[layers];//indicarnos cuantos nodos hay por capa

    //rellenar array
    for (int i =0; i< nodes.size(); i++) {
      nodesInLayers[nodes.get(i).layer] +=1;
    }

    //para cada capa las conexiones maximas es el numero de dicha capa por la cantidad de nodos delante de ella
    //sumar todos los valores de conexiones para la cantidad de conexiones totales
    for (int i = 0; i < layers-1; i++) {
      int nodesInFront = 0;
      for (int j = i+1; j < layers; j++) {//para cada posterior a esta
        nodesInFront += nodesInLayers[j];//añadir nodos
      }

      maxConnections += nodesInLayers[i] * nodesInFront;
    }

    if (maxConnections == genes.size()) {//si el numero de conexiones es igual al numero maximo de conexiones, indicamos que esta completamente conectada
      return true;
    }
    return false;
  }


  //mutar el genoma
  void mutate(ArrayList<connectionHistory> innovationHistory) {
    if (genes.size() ==0) {
      addConnection(innovationHistory);
    }

    float rand1 = random(1);
    if (rand1<=0.8) { // 80% del tiempo, muta el peso
      for (int i = 0; i< genes.size(); i++) {
        genes.get(i).mutateWeight();
      }
    }
    //5% del tiempo, añadimos una nueva conexion
    float rand2 = random(1);
    if (rand2<=0.05) {
      addConnection(innovationHistory);
    }


    //1% añadimos un nuevo nodo
    float rand3 = random(1);
    if (rand3<0.02) {
      addNode(innovationHistory);
    }
  }

  //cuando el genome es mejor que otro padre, lo llamamos
  Genome crossover(Genome parent2) {
    Genome child = new Genome(inputs, outputs, true);
    child.genes.clear();
    child.nodes.clear();
    child.layers = layers;
    child.nextNode = nextNode;
    child.biasNode = biasNode;
    ArrayList<connectionGene> childGenes = new ArrayList<connectionGene>();//lista de genes a heredar
    ArrayList<Boolean> isEnabled = new ArrayList<Boolean>(); 
    //genes heredados
    for (int i = 0; i< genes.size(); i++) {
      boolean setEnabled = true;//activar en el hijo

      int parent2gene = matchingGene(parent2, genes.get(i).innovationNo);
      if (parent2gene != -1) {//si los genes coinciden
        if (!genes.get(i).enabled || !parent2.genes.get(parent2gene).enabled) {//si alguno de los genes esta desactivado

          if (random(1) < 0.75) {//75% del tiempo, desactivar los genes del hijo
            setEnabled = false;
          }
        }
        float rand = random(1);
        if (rand<0.5) {
          childGenes.add(genes.get(i));

        } else {
          //gen del padre2
          childGenes.add(parent2.genes.get(parent2gene));
        }
      } else {//dividir gen
        childGenes.add(genes.get(i));
        setEnabled = genes.get(i).enabled;
      }
      isEnabled.add(setEnabled);
    }

    //como los genes son heredados del mejor padre, la estructura del hijo no es muy diferente, a exepcion de las conexiones durmientes, las cuales no afectan a los nodos
    for (int i = 0; i < nodes.size(); i++) {
      child.nodes.add(nodes.get(i).clone());
    }

    //clonar conexiones para conectar los nodos nuevos de los hijos

    for ( int i =0; i<childGenes.size(); i++) {
      child.genes.add(childGenes.get(i).clone(child.getNode(childGenes.get(i).fromNode.number), child.getNode(childGenes.get(i).toNode.number)));
      child.genes.get(i).enabled = isEnabled.get(i);
    }

    child.connectNodes();
    return child;
  }

  //crear genoma vacio
  Genome(int in, int out, boolean crossover) {
    //set input number and output number
    inputs = in; 
    outputs = out;
  }
  //devuelve el valor el matching del numero de innovacion del gen, en el genima de entrada
  int matchingGene(Genome parent2, int innovationNumber) {
    for (int i =0; i < parent2.genes.size(); i++) {
      if (parent2.genes.get(i).innovationNo == innovationNumber) {
        return i;
      }
    }
    return -1; //no hay gen
  }
  //imprime el valor del genoma en la consola
  void printGenome() {
    println("Print genome  layers:", layers);  
    println("bias node: "  + biasNode);
    println("nodes");
    for (int i = 0; i < nodes.size(); i++) {
      print(nodes.get(i).number + ",");
    }
    println("Genes");
    for (int i = 0; i < genes.size(); i++) {//para cada connectionGene
      println("gene " + genes.get(i).innovationNo, "From node " + genes.get(i).fromNode.number, "To node " + genes.get(i).toNode.number, 
        "is enabled " +genes.get(i).enabled, "from layer " + genes.get(i).fromNode.layer, "to layer " + genes.get(i).toNode.layer, "weight: " + genes.get(i).weight);
    }

    println();
  }

  //copiar el genoma
  Genome clone() {

    Genome clone = new Genome(inputs, outputs, true);

    for (int i = 0; i < nodes.size(); i++) {//copiar nodos
      clone.nodes.add(nodes.get(i).clone());
    }

    //copiar conexiones

    for ( int i =0; i<genes.size(); i++) {//copiar genes
      clone.genes.add(genes.get(i).clone(clone.getNode(genes.get(i).fromNode.number), clone.getNode(genes.get(i).toNode.number)));
    }

    clone.layers = layers;
    clone.nextNode = nextNode;
    clone.biasNode = biasNode;
    clone.connectNodes();

    return clone;
  }
  //dibujar genoma en la pantalla
  void drawGenome(int startX, int startY, int w, int h) {
    ArrayList<ArrayList<Node>> allNodes = new ArrayList<ArrayList<Node>>();
    ArrayList<PVector> nodePoses = new ArrayList<PVector>();
    ArrayList<Integer> nodeNumbers= new ArrayList<Integer>();

    //colocacion de los nodos en la pantalla


    //dividir los nodos en capas
    for (int i = 0; i< layers; i++) {
      ArrayList<Node> temp = new ArrayList<Node>();
      for (int j = 0; j< nodes.size(); j++) {//para cada nodo
        if (nodes.get(j).layer == i ) {//comprobar si esta en la capa
          temp.add(nodes.get(j)); //añadirlo a la capa
        }
      }
      allNodes.add(temp);//añadir capa a los nodos
    }

    //colocar los nodos en capas en la pantalla
    for (int i = 0; i < layers; i++) {
      fill(255, 0, 0);
      float x = startX + (float)((i)*w)/(float)(layers-1);
      for (int j = 0; j< allNodes.get(i).size(); j++) {//posicion de la capa
        float y = startY + ((float)(j + 1.0) * h)/(float)(allNodes.get(i).size() + 1.0);
        nodePoses.add(new PVector(x, y));
        nodeNumbers.add(allNodes.get(i).get(j).number);
        if(i == layers -1){
         println(i,j,x,y); 
          
          
        }
      }
    }

    //dibujar conexiones
    stroke(0);
    strokeWeight(2);
    for (int i = 0; i< genes.size(); i++) {
      if (genes.get(i).enabled) {
        stroke(0);
      } else {
        stroke(100);
      }
      PVector from;
      PVector to;
      from = nodePoses.get(nodeNumbers.indexOf(genes.get(i).fromNode.number));
      to = nodePoses.get(nodeNumbers.indexOf(genes.get(i).toNode.number));
      if (genes.get(i).weight > 0) {
        stroke(255, 0, 0);
      } else {
        stroke(0, 0, 255);
      }
      strokeWeight(map(abs(genes.get(i).weight), 0, 1, 0, 5));
      line(from.x, from.y, to.x, to.y);
    }

    //dibujar los nodods al final para que esten encimas de las conexiones
    for (int i = 0; i < nodePoses.size(); i++) {
      fill(255);
      stroke(0);
      strokeWeight(1);
      ellipse(nodePoses.get(i).x, nodePoses.get(i).y, 20, 20);
      textSize(10);
      fill(0);
      textAlign(CENTER, CENTER);


      text(nodeNumbers.get(i), nodePoses.get(i).x, nodePoses.get(i).y);
    }
  }
}

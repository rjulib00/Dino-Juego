class Node {
  int number;
  float inputSum = 0;//suma actual antes de la activacion
  float outputValue = 0; //despues de la activacion se aplica la funcion
  ArrayList<connectionGene> outputConnections = new ArrayList<connectionGene>();
  int layer = 0;
  PVector drawPos = new PVector();


  Node(int no) {
    number = no;
  }

  //el nodo envia su entrada a las entradas de los nodos conectados

  void engage() {
    if (layer!=0) {//
      outputValue = sigmoid(inputSum);
    }

    for (int i = 0; i< outputConnections.size(); i++) {//para cada conexion
      if (outputConnections.get(i).enabled) {//no hacer nada si no esta activado
        outputConnections.get(i).toNode.inputSum += outputConnections.get(i).weight * outputValue;//añadir el valor de lasila a la suma de los inputs de los nodos conectados
      }
    }
 }

  float stepFunction(float x) {
    if (x < 0) {
      return 0;
    } else {
      return 1;
    }
  }
  //funcion de activacion
  float sigmoid(float x) {
    float y = 1 / (1 + pow((float)Math.E, -4.9*x));
    return y;
  }
  //devolver si el nodo esta conectado al nodo parametro
  //se usa cuando se añade una nueva conexion
  boolean isConnectedTo(Node node) {
    if (node.layer == layer) {//nodos en la misma capa no se pueden conectar entre ellos
      return false;
    }

    if (node.layer < layer) {
      for (int i = 0; i < node.outputConnections.size(); i++) {
        if (node.outputConnections.get(i).toNode == this) {
          return true;
        }
      }
    } else {
      for (int i = 0; i < outputConnections.size(); i++) {
        if (outputConnections.get(i).toNode == node) {
          return true;
        }
      }
    }

    return false;
  }
  //devolver una copia del nodo
  Node clone() {
    Node clone = new Node(number);
    clone.layer = layer;
    return clone;
  }
}

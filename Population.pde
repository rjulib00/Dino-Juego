class Population {
  ArrayList<Player> pop = new ArrayList<Player>();
  Player bestPlayer; //el mejor jugador que ha aparecido
  int bestScore =0;//su puntuacion
  int gen;
  ArrayList<connectionHistory> innovationHistory = new ArrayList<connectionHistory>();
  ArrayList<Player> genPlayers = new ArrayList<Player>();
  ArrayList<Species> species = new ArrayList<Species>();

  boolean massExtinctionEvent = false;
  boolean newStage = false;
  int populationLife = 0;

  Population(int size) {
//crear la poblacion inicial
    for (int i =0; i<size; i++) {
      pop.add(new Player());
      pop.get(i).brain.generateNetwork();
      pop.get(i).brain.mutate(innovationHistory);
    }
  }
  //actualizar todos los "player"s vivos
  void updateAlive() {
    populationLife ++;
    for (int i = 0; i< pop.size(); i++) {
      if (!pop.get(i).dead) {
        pop.get(i).look();//leer las entradas a la red neuronal
        pop.get(i).think();//usar las salidas de la red neuronal
        pop.get(i).update();//movimiento del jugador, dependiendo lo que "piense" la red neuronal de ese player
        if (!showNothing) {
          pop.get(i).show();
        }
      }
    }
  }
  //comprobar si todos los jugadores actuales estan muertos
  boolean done() {
    for (int i = 0; i< pop.size(); i++) {
      if (!pop.get(i).dead) {
        return false;
      }
    }
    return true;
  }
  //comprobar el mejor player de esta generacion, y el mejor que ha aparecido
  void setBestPlayer() {
    Player tempBest =  species.get(0).players.get(0);
    tempBest.gen = gen;


    //si el de esta generacion es mejor que el mejor que ha habido, se pone el nuevo como el mejor

    if (tempBest.score > bestScore) {
      genPlayers.add(tempBest.cloneForReplay());
      println("old best:", bestScore);
      println("new best:", tempBest.score);
      bestScore = tempBest.score;
      bestPlayer = tempBest.cloneForReplay();
    }
  }

  //cuando todos mueren, se inicia una nueva generacion
  void naturalSelection() {
    speciate();
    calculateFitness();//calcular la habilidad de cada "player"
    sortSpecies();//ordenarlos de mas habilidad a menos
    if (massExtinctionEvent) { 
      massExtinction();
      massExtinctionEvent = false;
    }
    cullSpecies();//quitar los peores "player"s
    setBestPlayer();//guardar los mejores "player"s de esta generacion para usar en las siguientes
    killStaleSpecies();//matar "player"s que no han mejorado en 15 generaciones
    killBadSpecies();//eliminar a los peores


    println("generation", gen, "Number of mutations", innovationHistory.size(), "species: " + species.size(), "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");


    float averageSum = getAvgFitnessSum();
    ArrayList<Player> children = new ArrayList<Player>();//siguiente generacion
    println("Species:");               
    for (int j = 0; j < species.size(); j++) {//para cada "species"

      println("best unadjusted fitness:", species.get(j).bestFitness);
      for (int i = 0; i < species.get(j).players.size(); i++) {
        print("player " + i, "fitness: " +  species.get(j).players.get(i).fitness, "score " + species.get(j).players.get(i).score, ' ');
      }
      println();
      children.add(species.get(j).champ.clone());//crear campeon, sin ninguna mutacion

      int NoOfChildren = floor(species.get(j).averageFitness/averageSum * pop.size()) -1;//cantidad de hijos que esta species puede crear, el -1 representa el campeon
      for (int i = 0; i< NoOfChildren; i++) {//cantidad de hijos de la species actual
        children.add(species.get(j).giveMeBaby(innovationHistory));
      }
    }

    while (children.size() < pop.size()) {//si no se crean suficientes hijos
      children.add(species.get(0).giveMeBaby(innovationHistory));//obtenerlos de los mejores
    }
    pop.clear();
    pop = (ArrayList)children.clone(); //colocar a los hijos como la actual generacion
    gen+=1;
    for (int i = 0; i< pop.size(); i++) {//generar una red neuronal para cada hijo
      pop.get(i).brain.generateNetwork();
    }
    
    populationLife = 0;
  }

  //separar las poblaciones de species en funcion de como trabajan
  void speciate() {
    for (Species s : species) {//species vacio
      s.players.clear();
    }
    for (int i = 0; i< pop.size(); i++) {//cada player
      boolean speciesFound = false;
      for (Species s : species) {//cada species
        if (s.sameSpecies(pop.get(i).brain)) {//colo cacion de los "player"s en species parecidas
          s.addToSpecies(pop.get(i));
          speciesFound = true;
          break;
        }
      }
      if (!speciesFound) {//si no hay parecidas añadir una nueva especie como campeon
        species.add(new Species(pop.get(i)));
      }
    }
  }
  //calcular habilidad
  void calculateFitness() {
    for (int i =1; i<pop.size(); i++) {
      pop.get(i).calculateFitness();
    }
  }
  //ordenarlos por habilidad
  void sortSpecies() {
    //ordenarlos internamente entre species
    for (Species s : species) {
      s.sortSpecies();
    }

    //ordenar las species respecto a su mejor player
    ArrayList<Species> temp = new ArrayList<Species>();
    for (int i = 0; i < species.size(); i ++) {
      float max = 0;
      int maxIndex = 0;
      for (int j = 0; j< species.size(); j++) {
        if (species.get(j).bestFitness > max) {
          max = species.get(j).bestFitness;
          maxIndex = j;
        }
      }
      temp.add(species.get(maxIndex));
      species.remove(maxIndex);
      i--;
    }
    species = (ArrayList)temp.clone();
  }
  //matar a todos los que no mejoren en 10 generaciones
  void killStaleSpecies() {
    for (int i = 2; i< species.size(); i++) {
      if (species.get(i).staleness >= 10) {
        species.remove(i);
        i--;
      }
    }
  }
  //si una species es mala, matarla antes de que cree hijos
  void killBadSpecies() {
    float averageSum = getAvgFitnessSum();

    for (int i = 1; i< species.size(); i++) {
      if (species.get(i).averageFitness/averageSum * pop.size() < 1) {
        species.remove(i);
        i--;
      }
    }
  }
  //devolver la media de habilidad de cada species
  float getAvgFitnessSum() {
    float averageSum = 0;
    for (Species s : species) {
      averageSum += s.averageFitness;
    }
    return averageSum;
  }

  //matar a la mitad inferior de las species
  void cullSpecies() {
    for (Species s : species) {
      s.cull();
      s.fitnessSharing();
      s.setAverage();//recalcular la media de habilidad
    }
  }


  void massExtinction() {
    for (int i =5; i< species.size(); i++) {
      species.remove(i);
      i--;
    }
  }
}

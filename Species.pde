class Species {
  ArrayList<Player> players = new ArrayList<Player>();
  float bestFitness = 0;
  Player champ;
  float averageFitness = 0;
  int staleness = 0;//numero de generaciones sin mejorar
  Genome rep;

  /*---------variables de comprobacion------------*/
  float excessCoeff = 1;
  float weightDiffCoeff = 0.5;
  float compatibilityThreshold = 3;

  Species() {//constructor vacio
  }


  //constructor que coge un player de una species
  Species(Player p) {
    players.add(p); 
    //como es el unico en la species, es por defecto el mejor
    bestFitness = p.fitness; 
    rep = p.brain.clone();
    champ = p.cloneForReplay();
  }

  //devuelve el parametro genome de dicha species
  boolean sameSpecies(Genome g) {
    float compatibility;
    float excessAndDisjoint = getExcessDisjoint(g, rep);//diferencias entre los "genes" del player y la species
    float averageWeightDiff = averageWeightDiff(g, rep);//media de genes


    float largeGenomeNormaliser = g.genes.size() - 20;
    if (largeGenomeNormaliser<1) {
      largeGenomeNormaliser =1;
    }

    compatibility =  (excessCoeff* excessAndDisjoint/largeGenomeNormaliser) + (weightDiffCoeff* averageWeightDiff);
    return (compatibilityThreshold > compatibility);
  }

  //añadir player a la species
  void addToSpecies(Player p) {
    players.add(p);
  }

  //devuelve el numero de genes diferentes
  float getExcessDisjoint(Genome brain1, Genome brain2) {
    float matching = 0.0;
    for (int i =0; i <brain1.genes.size(); i++) {
      for (int j = 0; j < brain2.genes.size(); j++) {
        if (brain1.genes.get(i).innovationNo == brain2.genes.get(j).innovationNo) {
          matching ++;
          break;
        }
      }
    }
    return (brain1.genes.size() + brain2.genes.size() - 2*(matching));
  }
  //devuelve la diferencia entre genes
  float averageWeightDiff(Genome brain1, Genome brain2) {
    if (brain1.genes.size() == 0 || brain2.genes.size() ==0) {
      return 0;
    }


    float matching = 0;
    float totalDiff= 0;
    for (int i =0; i <brain1.genes.size(); i++) {
      for (int j = 0; j < brain2.genes.size(); j++) {
        if (brain1.genes.get(i).innovationNo == brain2.genes.get(j).innovationNo) {
          matching ++;
          totalDiff += abs(brain1.genes.get(i).weight - brain2.genes.get(j).weight);
          break;
        }
      }
    }
    if (matching ==0) {//por si hay division ÷0
      return 100;
    }
    return totalDiff/matching;
  }
  //ordenar la species por habilidad
  void sortSpecies() {

    ArrayList<Player> temp = new ArrayList<Player>();
 
    for (int i = 0; i < players.size(); i ++) {
      float max = 0;
      int maxIndex = 0;
      for (int j = 0; j< players.size(); j++) {
        if (players.get(j).fitness > max) {
          max = players.get(j).fitness;
          maxIndex = j;
        }
      }
      temp.add(players.get(maxIndex));
      players.remove(maxIndex);
      i--;
    }

    players = (ArrayList)temp.clone();
    if (players.size() == 0) {
      print("fucking"); 
      staleness = 200;
      return;
    }
    //en caso de que haya un nuevo mejor player
    if (players.get(0).fitness > bestFitness) {
      staleness = 0;
      bestFitness = players.get(0).fitness;
      rep = players.get(0).brain.clone();
      champ = players.get(0).cloneForReplay();
    } else {
      staleness ++;
    }
  }

  //media
  void setAverage() {

    float sum = 0;
    for (int i = 0; i < players.size(); i ++) {
      sum += players.get(i).fitness;
    }
    averageFitness = sum/players.size();
  }
  //obtener los hijos de la species actual
  Player giveMeBaby(ArrayList<connectionHistory> innovationHistory) {
    Player baby;
    if (random(1) < 0.25) {//25% de las veces no hay crossbreeding y es simplemente un clon
      baby =  selectPlayer().clone();
    } else {//75% hay crossbreeding

      //obtener 2 padres aleatorios
      Player parent1 = selectPlayer();
      Player parent2 = selectPlayer();

      //el cruce espera la habilidad maxima como objeto y la menor como argumento
      if (parent1.fitness < parent2.fitness) {
        baby =  parent2.crossover(parent1);
      } else {
        baby =  parent1.crossover(parent2);
      }
    }
    baby.brain.mutate(innovationHistory);//mutar el cerebro
    return baby;
  }

  //seleccionar jugadores en funcion de su habilidad
  Player selectPlayer() {
    float fitnessSum = 0;
    for (int i =0; i<players.size(); i++) {
      fitnessSum += players.get(i).fitness;
    }

    float rand = random(fitnessSum);
    float runningSum = 0;

    for (int i = 0; i<players.size(); i++) {
      runningSum += players.get(i).fitness; 
      if (runningSum > rand) {
        return players.get(i);
      }
    }
    return players.get(0);
  }
  //matar la mitad de la tabla de species (los peores)
  void cull() {
    if (players.size() > 2) {
      for (int i = players.size()/2; i<players.size(); i++) {
        players.remove(i); 
        i--;
      }
    }
  }
  //para proteger a los "player"s unicos, la habilidad de cada uno se divide entre el numero de "player"s de dicha species
  void fitnessSharing() {
    for (int i = 0; i< players.size(); i++) {
      players.get(i).fitness/=players.size();
    }
  }
}

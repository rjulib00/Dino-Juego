class Player {
  float fitness;
  Genome brain;
  boolean replay = false;

  float unadjustedFitness;
  int lifespan = 0;//cuanto tiempo se viva para la adaptacion
  int bestScore =0;//guarda la mejor puntuacion para el reinicio
  boolean dead;
  int score;
  int gen = 0;

  int genomeInputs = 7;
  int genomeOutputs = 3;

  float[] vision = new float[genomeInputs];//el array de entradas que proveee de datos a la red neuronal
  float[] decision = new float[genomeOutputs]; //salida de la red neuronal
  //-------------------------------------
  float posY = 0;
  float velY = 0;
  float gravity =1.2;
  int runCount = -5;
  int size = 20;

  ArrayList<Obstacle> replayObstacles = new ArrayList<Obstacle>();
  ArrayList<Bird> replayBirds = new ArrayList<Bird>();
  ArrayList<Integer> localObstacleHistory = new ArrayList<Integer>();
  ArrayList<Integer> localRandomAdditionHistory = new ArrayList<Integer>();
  int historyCounter = 0;
  int localObstacleTimer = 0;
  float localSpeed = 10;
  int localRandomAddition = 0;

  boolean duck = false;

  Player() {
    brain = new Genome(genomeInputs, genomeOutputs);
  }
//dibujar dinosaurio
  void show() {
    if (duck && posY == 0) {
      if (runCount < 0) {

        image(dinoDuck, playerXpos - dinoDuck.width/2, height - groundHeight - (posY + dinoDuck.height));
      } else {

        image(dinoDuck1, playerXpos - dinoDuck1.width/2, height - groundHeight - (posY + dinoDuck1.height));
      }
    } else
      if (posY ==0) {
        if (runCount < 0) {
          image(dinoRun1, playerXpos - dinoRun1.width/2, height - groundHeight - (posY + dinoRun1.height));
        } else {
          image(dinoRun2, playerXpos - dinoRun2.width/2, height - groundHeight - (posY + dinoRun2.height));
        }
      } else {
        image(dinoJump, playerXpos - dinoJump.width/2, height - groundHeight - (posY + dinoJump.height));
      }
    runCount++;
    if (runCount > 5) {
      runCount = -5;
    }
  }
   
  void incrementCounters() {
    lifespan++;
    if (lifespan % 3 ==0) {
      score+=1;
    }
  }

  //control de colisiones (hitboxes), y en caso de que se pierda, reiniciarlo
  void move() {
    posY += velY;
    if (posY >0) {
      velY -= gravity;
    } else {
      velY = 0;
      posY = 0;
    }

    if (!replay) {

      for (int i = 0; i< obstacles.size(); i++) {
        if (obstacles.get(i).collided(playerXpos, posY +dinoRun1.height/2, dinoRun1.width*0.5, dinoRun1.height)) {
          dead = true;
        }
      }

      for (int i = 0; i< birds.size(); i++) {
        if (duck && posY ==0) {
          if (birds.get(i).collided(playerXpos, posY + dinoDuck.height/2, dinoDuck.width*0.8, dinoDuck.height)) {
            dead = true;
          }
        } else {
          if (birds.get(i).collided(playerXpos, posY +dinoRun1.height/2, dinoRun1.width*0.5, dinoRun1.height)) {
            dead = true;
          }
        }
      }
    } else {//desplazar los obstaculos actuales en caso de que se reinicie
      for (int i = 0; i< replayObstacles.size(); i++) {
        if (replayObstacles.get(i).collided(playerXpos, posY +dinoRun1.height/2, dinoRun1.width*0.5, dinoRun1.height)) {
          dead = true;
        }
      }


      for (int i = 0; i< replayBirds.size(); i++) {
        if (duck && posY ==0) {
          if (replayBirds.get(i).collided(playerXpos, posY + dinoDuck.height/2, dinoDuck.width*0.8, dinoDuck.height)) {
            dead = true;
          }
        } else {
          if (replayBirds.get(i).collided(playerXpos, posY +dinoRun1.height/2, dinoRun1.width*0.5, dinoRun1.height)) {
            dead = true;
          }
        }
      }
    }
  }

  void jump(boolean bigJump) {
    if (posY ==0) {
      if (bigJump) {
        gravity = 1;
        velY = 20;
      } else {
        gravity = 1.2;
        velY = 16;
      }
    }
  }

 //incrementar la gravedad en caso de que sea cierto
  void ducking(boolean isDucking) {
    if (posY != 0 && isDucking) {
      gravity = 3;
    }
    duck = isDucking;
  }

  void update() {
    incrementCounters();
    move();
  }
  //Datos para la red neuronal
  void look() {
    if (!replay) {
      float temp = 0;
      float min = 10000;
      int minIndex = -1;
      boolean berd = false; 
      for (int i = 0; i< obstacles.size(); i++) {
        if (obstacles.get(i).posX + obstacles.get(i).w/2 - (playerXpos - dinoRun1.width/2) < min &&  obstacles.get(i).posX + obstacles.get(i).w/2 - (playerXpos - dinoRun1.width/2) > 0) {//la minima distancia entre la izquierda del jugador y la derecha del obstaculo
          min = obstacles.get(i).posX + obstacles.get(i).w/2 - (playerXpos - dinoRun1.width/2);
          minIndex = i;
        }
      }

      for (int i = 0; i< birds.size(); i++) {
        if (birds.get(i).posX + birds.get(i).w/2 - (playerXpos - dinoRun1.width/2) < min &&  birds.get(i).posX + birds.get(i).w/2 - (playerXpos - dinoRun1.width/2) > 0) {//lo mismo que el if anterior, pero para los pajaros
          min = birds.get(i).posX + birds.get(i).w/2 - (playerXpos - dinoRun1.width/2);
          minIndex = i;
          berd = true;
        }
      }
      vision[4] = speed;
      vision[5] = posY;


      if (minIndex == -1) {//en caso de no haber obstaculos
        vision[0] = 0; 
        vision[1] = 0;
        vision[2] = 0;
        vision[3] = 0;
        vision[6] = 0;
      } else {

        vision[0] = 1.0/(min/10.0);
        if (berd) {
          vision[1] = birds.get(minIndex).h;
          vision[2] = birds.get(minIndex).w;
          if (birds.get(minIndex).typeOfBird == 0) {
            vision[3] = 0;
          } else {
            vision[3] = birds.get(minIndex).posY;
          }
        } else {
          vision[1] = obstacles.get(minIndex).h;
          vision[2] = obstacles.get(minIndex).w;
          vision[3] = 0;
        }




        //vision[6] es el espacio entre el obstaculo actual y el siguiente
        int bestIndex = minIndex;
        float closestDist = min;
        min = 10000;
        minIndex = -1;
        for (int i = 0; i< obstacles.size(); i++) {
          if ((berd || i != bestIndex) && obstacles.get(i).posX + obstacles.get(i).w/2 - (playerXpos - dinoRun1.width/2) < min &&  obstacles.get(i).posX + obstacles.get(i).w/2 - (playerXpos - dinoRun1.width/2) > 0) {
            min = obstacles.get(i).posX + obstacles.get(i).w/2 - (playerXpos - dinoRun1.width/2);
            minIndex = i;
          }
        }

        for (int i = 0; i< birds.size(); i++) {
          if ((!berd || i != bestIndex) && birds.get(i).posX + birds.get(i).w/2 - (playerXpos - dinoRun1.width/2) < min &&  birds.get(i).posX + birds.get(i).w/2 - (playerXpos - dinoRun1.width/2) > 0) {
            min = birds.get(i).posX + birds.get(i).w/2 - (playerXpos - dinoRun1.width/2);
            minIndex = i;
          }
        }

        if (minIndex == -1) {//en caso de que haya 1 unico objeto dibujado
          vision[6] = 0;
        } else {
          vision[6] = 1/(min - closestDist);
        }
      }
    } else {//si se reinicia, actualizar con los datos de la partida enterior (solo funciona mientras el juego este funcionando
      float temp = 0;
      float min = 10000;
      int minIndex = -1;
      boolean berd = false; 
      for (int i = 0; i< replayObstacles.size(); i++) {
        if (replayObstacles.get(i).posX + replayObstacles.get(i).w/2 - (playerXpos - dinoRun1.width/2) < min &&  replayObstacles.get(i).posX + replayObstacles.get(i).w/2 - (playerXpos - dinoRun1.width/2) > 0) {
          min = replayObstacles.get(i).posX + replayObstacles.get(i).w/2 - (playerXpos - dinoRun1.width/2);
          minIndex = i;
        }
      }

      for (int i = 0; i< replayBirds.size(); i++) {
        if (replayBirds.get(i).posX + replayBirds.get(i).w/2 - (playerXpos - dinoRun1.width/2) < min &&  replayBirds.get(i).posX + replayBirds.get(i).w/2 - (playerXpos - dinoRun1.width/2) > 0) {
          min = replayBirds.get(i).posX + replayBirds.get(i).w/2 - (playerXpos - dinoRun1.width/2);
          minIndex = i;
          berd = true;
        }
      }
      vision[4] = localSpeed;
      vision[5] = posY;


      if (minIndex == -1) {
        vision[0] = 0; 
        vision[1] = 0;
        vision[2] = 0;
        vision[3] = 0;
        vision[6] = 0;
      } else {

        vision[0] = 1.0/(min/10.0);
        if (berd) {
          vision[1] = replayBirds.get(minIndex).h;
          vision[2] = replayBirds.get(minIndex).w;
          if (replayBirds.get(minIndex).typeOfBird == 0) {
            vision[3] = 0;
          } else {
            vision[3] = replayBirds.get(minIndex).posY;
          }
        } else {
          vision[1] = replayObstacles.get(minIndex).h;
          vision[2] = replayObstacles.get(minIndex).w;
          vision[3] = 0;
        }




        int bestIndex = minIndex;
        float closestDist = min;
        min = 10000;
        minIndex = -1;
        for (int i = 0; i< replayObstacles.size(); i++) {
          if ((berd || i != bestIndex) && replayObstacles.get(i).posX + replayObstacles.get(i).w/2 - (playerXpos - dinoRun1.width/2) < min &&  replayObstacles.get(i).posX + replayObstacles.get(i).w/2 - (playerXpos - dinoRun1.width/2) > 0) {
            min = replayObstacles.get(i).posX + replayObstacles.get(i).w/2 - (playerXpos - dinoRun1.width/2);
            minIndex = i;
          }
        }

        for (int i = 0; i< replayBirds.size(); i++) {
          if ((!berd || i != bestIndex) && replayBirds.get(i).posX + replayBirds.get(i).w/2 - (playerXpos - dinoRun1.width/2) < min &&  replayBirds.get(i).posX + replayBirds.get(i).w/2 - (playerXpos - dinoRun1.width/2) > 0) {
            min = replayBirds.get(i).posX + replayBirds.get(i).w/2 - (playerXpos - dinoRun1.width/2);
            minIndex = i;
          }
        }

        if (minIndex == -1) {
          vision[6] = 0;
        } else {
          vision[6] = 1/(min - closestDist);
        }
      }
    }
  }

  //Recoge la salida del "cerebro" y lo convierte en acciones
  void think() {

    float max = 0;
    int maxIndex = 0;
    //datos de la red neuronal
    decision = brain.feedForward(vision);

    for (int i = 0; i < decision.length; i++) {
      if (decision[i] > max) {
        max = decision[i];
        maxIndex = i;
      }
    }

    if (max < 0.7) {
      ducking(false);
      return;
    }

    switch(maxIndex) {
    case 0:
      jump(false);
      break;
    case 1:
      jump(true);
      break;
    case 2:
      ducking(true);
      break;
    }
  }

  //clona un "jugador" con los datos actuales de la red neuronal
  Player clone() {
    Player clone = new Player();
    clone.brain = brain.clone();
    clone.fitness = fitness;
    clone.brain.generateNetwork(); 
    clone.gen = gen;
    clone.bestScore = score;
    return clone;
  }

  //eliminar cierta parte del RNG que se genera
  Player cloneForReplay() {
    Player clone = new Player();
    clone.brain = brain.clone();
    clone.fitness = fitness;
    clone.brain.generateNetwork();
    clone.gen = gen;
    clone.bestScore = score;
    clone.replay = true;
    if (replay) {
      clone.localObstacleHistory = (ArrayList)localObstacleHistory.clone();
      clone.localRandomAdditionHistory = (ArrayList)localRandomAdditionHistory.clone();
    } else {
      clone.localObstacleHistory = (ArrayList)obstacleHistory.clone();
      clone.localRandomAdditionHistory = (ArrayList)randomAdditionHistory.clone();
    }

    return clone;
  }

  //Algoritmo genetico
  void calculateFitness() {
    fitness = score*score;
  }

  //"herencia"
  Player crossover(Player parent2) {
    Player child = new Player();
    child.brain = brain.crossover(parent2.brain);
    child.brain.generateNetwork();
    return child;
  }
  //si se reinicia el "player" tiene obstaculos locales
  void updateLocalObstacles() {
    localObstacleTimer ++;
    localSpeed += 0.002;
    if (localObstacleTimer > minimumTimeBetweenObstacles + localRandomAddition) {
      addLocalObstacle();
    }
    groundCounter ++;
    if (groundCounter > 10) {
      groundCounter =0;
      grounds.add(new Ground());
    }

    moveLocalObstacles();
    showLocalObstacles();
  }

  void moveLocalObstacles() {
    for (int i = 0; i< replayObstacles.size(); i++) {
      replayObstacles.get(i).move(localSpeed);
      if (replayObstacles.get(i).posX < -100) {
        replayObstacles.remove(i);
        i--;
      }
    }

    for (int i = 0; i< replayBirds.size(); i++) {
      replayBirds.get(i).move(localSpeed);
      if (replayBirds.get(i).posX < -100) {
        replayBirds.remove(i);
        i--;
      }
    }
    for (int i = 0; i < grounds.size(); i++) {
      grounds.get(i).move(localSpeed);
      if (grounds.get(i).posX < -100) {
        grounds.remove(i);
        i--;
      }
    }
  }
 
  void addLocalObstacle() {
    int tempInt = localObstacleHistory.get(historyCounter);
    localRandomAddition = localRandomAdditionHistory.get(historyCounter);
    historyCounter ++;
    if (tempInt < 3) {
      replayBirds.add(new Bird(tempInt));
    } else {
      replayObstacles.add(new Obstacle(tempInt -3));
    }
    localObstacleTimer = 0;
  }
 
  void showLocalObstacles() {
    for (int i = 0; i< grounds.size(); i++) {
      grounds.get(i).show();
    }
    for (int i = 0; i< replayObstacles.size(); i++) {
      replayObstacles.get(i).show();
    }

    for (int i = 0; i< replayBirds.size(); i++) {
      replayBirds.get(i).show();
    }
  }
}
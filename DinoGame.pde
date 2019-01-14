int nextConnectionNo = 1000;
Population pop;
int frameSpeed = 60;


boolean showBestEachGen = false;
int upToGen = 0;
Player genPlayerTemp;

boolean showNothing = false;


//images
PImage dinoRun1, dinoRun2, dinoJump, dinoDuck, dinoDuck1, smallCactus, manySmallCactus, bigCactus, bird, bird1;


ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
ArrayList<Bird> birds = new ArrayList<Bird>();
ArrayList<Ground> grounds = new ArrayList<Ground>();


int obstacleTimer = 0;
int minimumTimeBetweenObstacles = 60;
int randomAddition = 0;
int groundCounter = 0;
float speed = 10;

int groundHeight = 250;
int playerXpos = 150;

ArrayList<Integer> obstacleHistory = new ArrayList<Integer>();
ArrayList<Integer> randomAdditionHistory = new ArrayList<Integer>();



//--------------------------------------------------------------------------------------------------------------------------------------------------
//inicializar la ejecucion, preparando las imagenes que va a cargar cada "modelo", al iniciar la ejecucion, mas adelante puede ser modificada insitu
void setup() {

  frameRate(60);
  size(1550, 850); //tamaño de la ventana, se puede cambiar por fullscreen(), o sus dimensiones
  dinoRun1 = loadImage("dinorun0000.png");
  dinoRun2 = loadImage("dinorun0001.png");
  dinoJump = loadImage("dinoJump0000.png");
  dinoDuck = loadImage("dinoduck0000.png");
  dinoDuck1 = loadImage("dinoduck0001.png");

  smallCactus = loadImage("cactusSmall0000.png");
  bigCactus = loadImage("cactusBig0000.png");
  manySmallCactus = loadImage("cactusSmallMany0000.png");
  bird = loadImage("berd.png");
  bird1 = loadImage("berd2.png");

  pop = new Population(50); //cuantos dinosaurios aparecen por generacion
}
//--------------------------------------------------------------------------------------------------------------------------------------------------------
//creamos las clases para dibujar la pantalla/ventana, y sus respectivos "player"s y "obstacle"s
void draw() {
  drawToScreen();
  if (showBestEachGen) {//mostrar lo mejor de cada generacion
    if (!genPlayerTemp.dead) {//si el actual "player" de la generacion no esta muerto, se actualiza
      genPlayerTemp.updateLocalObstacles();
      genPlayerTemp.look();
      genPlayerTemp.think();
      genPlayerTemp.update();
      genPlayerTemp.show();
    } else {//si mueren todos los "players", vamos a la siguiente generacion
      upToGen ++;
      if (upToGen >= pop.genPlayers.size()) {//si es el final, reiniciar los "players"
        upToGen= 0;
        showBestEachGen = false;
      } else {
        genPlayerTemp = pop.genPlayers.get(upToGen).cloneForReplay();
      }
    }
  } else {//evolucion normal
    if (!pop.done()) {//actualizar a los "players" actuales
      updateObstacles();
      pop.updateAlive();
    } else {//todos muertos
      //algoritmo de generacion
      pop.naturalSelection();
      resetObstacles();
    }
  }
}



//---------------------------------------------------------------------------------------------------------------------------------------------------------
//dibujar la ventana
void drawToScreen() {
  if (!showNothing) {
    background(250); 
    stroke(0);
    strokeWeight(2);
    line(0, height - groundHeight - 30, width, height - groundHeight - 30);
    drawBrain();
    writeInfo();
  }
}
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
void drawBrain() {  //se dibuja en la parte de arriba, lo que realiza la generacion actual
  int startX = 600;
  int startY = 10;
  int w = 600;
  int h = 400;
  if (showBestEachGen) {
    genPlayerTemp.brain.drawGenome(startX, startY, w, h);
  } else {
    for (int i = 0; i< pop.pop.size(); i++) {
      if (!pop.pop.get(i).dead) {
        pop.pop.get(i).brain.drawGenome(startX, startY, w, h);
        break;
      }
    }
  }
}
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//informacion del "player" o "player"s que haya actualmente
void writeInfo() {
  fill(200);
  textAlign(LEFT);
  textSize(40);
  if (showBestEachGen) { //dibujar la informacion necesaria de la mejor generacion
    text("Score: " + genPlayerTemp.score, 30, height - 30);
    //text(, width/2-180, height-30);
    textAlign(RIGHT);
    text("Gen: " + (genPlayerTemp.gen +1), width -40, height-30);
    textSize(20);
    int x = 580;
    text("Distace to next obstacle", x, 18+44.44444);
    text("Height of obstacle", x, 18+2*44.44444);
    text("Width of obstacle", x, 18+3*44.44444);
    text("Bird height", x, 18+4*44.44444);
    text("Speed", x, 18+5*44.44444);
    text("Players Y position", x, 18+6*44.44444);
    text("Gap between obstacles", x, 18+7*44.44444);
    text("Bias", x, 18+8*44.44444);

    textAlign(LEFT);
    text("Small Jump", 1220, 118);
    text("Big Jump", 1220, 218);
    text("Duck", 1220, 318);
  } else { //evolucion
    text("Score: " + floor(pop.populationLife/3.0), 30, height - 30);
    //text(, width/2-180, height-30);
    text("Gen: " + (pop.gen +1), 30, height - 75);
    textAlign(RIGHT);

    //text("Gen: " + (pop.gen +1), width -40, height-30);
    textSize(20);
    int x = 580;
    text("Distace to next obstacle", x, 18+44.44444);
    text("Height of obstacle", x, 18+2*44.44444);
    text("Width of obstacle", x, 18+3*44.44444);
    text("Bird height", x, 18+4*44.44444);
    text("Speed", x, 18+5*44.44444);
    text("Players Y position", x, 18+6*44.44444);
    text("Gap between obstacles", x, 18+7*44.44444);
    text("Bias", x, 18+8*44.44444);

    textAlign(LEFT);
    text("Small Jump", 1220, 118);
    text("Big Jump", 1220, 218);
    text("Duck", 1220, 318);
  }
}


//--------------------------------------------------------------------------------------------------------------------------------------------------
//acciones de tecla, no para juego, si no para apoyo de computo
void keyPressed() {
  switch(key) {
  case '+'://aumentar framerate()
    frameSpeed += 10;
    frameRate(frameSpeed);
    println(frameSpeed);
    break;
  case '-'://ralentizar
    if (frameSpeed > 10) {
      frameSpeed -= 10;
      frameRate(frameSpeed);
      println(frameSpeed);
    }
    break;
  case 'g'://mostrar generaciones
    showBestEachGen = !showBestEachGen;
    upToGen = 0;
    genPlayerTemp = pop.genPlayers.get(upToGen).cloneForReplay();
    break;
  case 'n'://eliminar toda la interfaz para aumentar la velocidad de computo
    showNothing = !showNothing;
    break;
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------------------------
//funcion que se usa a cada frame/imagen
void updateObstacles() {
  obstacleTimer ++;
  speed += 0.002;
  if (obstacleTimer > minimumTimeBetweenObstacles + randomAddition) { //si el tiempo entre obstaculos minimunTimeBetweenObstacles es menor que el tiempo, se añade un obstaculo nuevo
    addObstacle();
  }
  groundCounter ++;
  if (groundCounter> 10) { //se añade un "ground bit"
    groundCounter =0;
    grounds.add(new Ground());
  }

  moveObstacles();//mover todo
  if (!showNothing) {//mostrar todo
    showObstacles();
  }
}

//---------------------------------------------------------------------------------------------------------------------------------------------------------
//mover obstaculos a la izquierda, basandose en la velocidad del juego
void moveObstacles() {
  println(speed);
  for (int i = 0; i< obstacles.size(); i++) {
    obstacles.get(i).move(speed);
    if (obstacles.get(i).posX < -playerXpos) { 
      obstacles.remove(i);
      i--;
    }
  }

  for (int i = 0; i< birds.size(); i++) {
    birds.get(i).move(speed);
    if (birds.get(i).posX < -playerXpos) {
      birds.remove(i);
      i--;
    }
  }
  for (int i = 0; i < grounds.size(); i++) {
    grounds.get(i).move(speed);
    if (grounds.get(i).posX < -playerXpos) {
      grounds.remove(i);
      i--;
    }
  }
}
//------------------------------------------------------------------------------------------------------------------------------------------------------------
//añadir obstaculos de vez en cuando
void addObstacle() {
  int lifespan = pop.populationLife;
  int tempInt;
  if (lifespan > 1000 && random(1) <= 0.15) { // el 15% del tiempo, se añade un pajaro
    tempInt = floor(random(3));
    Bird temp = new Bird(tempInt);
    birds.add(temp);
  } else {//añadir cactus
    tempInt = floor(random(3));
    Obstacle temp = new Obstacle(tempInt);
    obstacles.add(temp);
    tempInt+=3;
  }
  obstacleHistory.add(tempInt);

  randomAddition = floor(random(50));
  randomAdditionHistory.add(randomAddition);
  obstacleTimer = 0;
}
//---------------------------------------------------------------------------------------------------------------------------------------------------------

void showObstacles() {
  for (int i = 0; i< grounds.size(); i++) {
    grounds.get(i).show();
  }
  for (int i = 0; i< obstacles.size(); i++) {
    obstacles.get(i).show();
  }

  for (int i = 0; i< birds.size(); i++) {
    birds.get(i).show();
  }
}

//-------------------------------------------------------------------------------------------------------------------------------------------
//reiniciar los obstaculos (el mapa) cuando todos los dinosaurios han muerto
void resetObstacles() {
  randomAdditionHistory = new ArrayList<Integer>();
  obstacleHistory = new ArrayList<Integer>();

  obstacles = new ArrayList<Obstacle>();
  birds = new ArrayList<Bird>();
  obstacleTimer = 0;
  randomAddition = 0;
  groundCounter = 0;
  speed = 10;
}

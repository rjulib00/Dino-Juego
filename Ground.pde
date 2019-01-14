//mostrar cuadraditos en el suelo, es completamente innecesaria, solo esta hecha por dotar de "mas variedad" al suelo
//si se quiere quitar hay que quitar su llamada en main.pde

class Ground{
  float posX = width;
  float posY = height -floor(random(groundHeight - 20,groundHeight +30));
  int w = floor(random(1,10));
  
  Ground(){}
 
  void show(){
    stroke(0);
    strokeWeight(3);
    line(posX,posY, posX + w, posY);

  }
  void move(float speed) {
    posX -= speed;
  } 
}

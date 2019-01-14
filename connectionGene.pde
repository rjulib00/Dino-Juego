class connectionGene {
  Node fromNode;
  Node toNode;
  float weight;
  boolean enabled = true;
  int innovationNo;//cada conexion tiene un numero de innovacion para comparar genomas

//constructor
  connectionGene(Node from, Node to, float w, int inno) {
    fromNode = from;
    toNode = to;
    weight = w;
    innovationNo = inno;
  }

  //cambiar el peso/valor del gen
  void mutateWeight() {
    float rand2 = random(1);
    if (rand2 < 0.1) {//10% del tiempo cambia el peso completamente
      weight = random(-1, 1);
    } else {//cambiarlo ligeramente
      weight += randomGaussian()/50;
      //mantener pesos entre uniones
      if(weight > 1){
        weight = 1;
      }
      if(weight < -1){
        weight = -1;        
        
      }
    }
  }

  //copiar la conexion del genoma
  connectionGene clone(Node from, Node  to) {
    connectionGene clone = new connectionGene(from, to, weight, innovationNo);
    clone.enabled = enabled;

    return clone;
  }
}

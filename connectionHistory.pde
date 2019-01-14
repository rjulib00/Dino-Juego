class connectionHistory {
  int fromNode;
  int toNode;
  int innovationNumber;

  ArrayList<Integer> innovationNumbers = new ArrayList<Integer>();//el numero de innovacion de las conexiones del genoma que obtuvo la mutacion
  //representa el genoma, permite la comprobacion entre genomas
  //anterior a la conexion


//constructor
  connectionHistory(int from, int to, int inno, ArrayList<Integer> innovationNos) {
    fromNode = from;
    toNode = to;
    innovationNumber = inno;
    innovationNumbers = (ArrayList)innovationNos.clone();
  }
  //devuelve donde es igual el genoma y la conexion entre los mismo nodos
  boolean matches(Genome genome, Node from, Node to) {
    if (genome.genes.size() == innovationNumbers.size()) { //si la cantidad de conexiones son diferentes, no son el mismo genoma
      if (from.number == fromNode && to.number == toNode) {
        //comprobar si los numeros de innovacion coinciden con el genoma
        for (int i = 0; i< genome.genes.size(); i++) {
          if (!innovationNumbers.contains(genome.genes.get(i).innovationNo)) {
            return false;
          }
        }

        // si llega aqui el innovationNumbers coincide con el numero de innovacion y las conexiones entre los mismos nodos
        return true;
      }
    }
    return false;
  }
}

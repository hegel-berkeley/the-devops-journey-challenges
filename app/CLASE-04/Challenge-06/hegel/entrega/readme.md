## Clase 4 - reto 6

* Se creo el archivo lab.sh que contiene el paso a paso para la creacion de la imagen, contenedor con base de python.
* Se ejecuta el archivo lab.sh para la creacion de la nueva imagen en base a un dockerfile, login y publicacion
![Ejecutar el archivo lab.sh](img-1.png)

* Ingersar en el browser la url http://localhost:5000.
![Abrir localhost:5000](img-3.png)

* Nuevas imagenes en https://hub.docker.com/u/hegelberkeley
![DB](img-4.png)

* Eliminamos el contenedor y la imagen `docker rm -f $(docker ps -aq)` `docker rmi -f $(docker images -aq)`.
  ![Elimianr imagen contenedor](img-2.png)
## Clase 4 - reto 5

* Se creo el archivo lab.sh que contiene el paso a paso para la creacion de la imagen, contenedor con base de python.
* Se ejecuta el archivo lab.sh para la descarga de la imagen base, crear la nueva imagen y creacion del contenedor creacion de los nuevos tag, login en docker hub, push de las nuevas images
![Ejecutar el archivo lab.sh](img-1.png)
![Ejecutar el archivo lab.sh](img-2.png)
![Ejecutar el archivo lab.sh](img-3.png)
* ![Ejecutar el archivo lab.sh](img-4.png)

* Se ejecuta el comando `docker ps` para verificar que los contenedores se crearan con las nuevas imagenes.
![Ejecutar el comando docker ps](img-5.png)

* Nuevas imagenes en https://hub.docker.com/u/hegelberkeley
![DB](img-6.png)

* Eliminamos el contenedor y la imagen `docker rm -f mynginx` `docker rmi simple-nginx`.
![remove](img-7.png)
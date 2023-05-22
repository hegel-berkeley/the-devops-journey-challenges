## Clase 4 - reto 3

* Se creo el archivo lab.sh que contiene el paso a paso para la creacion del contenedor de nginx.
* Se ejecuta el archivo lab.sh para la descarga de la imagen y creacion del contenedor
![Ejecutar el archivo lab.sh](img-1.png)

* Se ejecuta el comando `docker ps` para verificar que el contenedor se creara correctamente.
![Ejecutar el comando docker ps](img-2.png)

* En el browser ingresamos http://localhost:9999 para ver que se visualice la web correctamente
![DB](img-3.png)

* Eliminamos los contenedores y las imagenes `docker rm -f bootcamp-web` `docker rmi nginx:alpine3.17-slim`.
![remove](img-4.png)
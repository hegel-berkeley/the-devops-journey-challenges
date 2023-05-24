#!/bin/bash

if [ ! -f /etc/init.d/docker ]; then
    echo "Docker no está instalado. https://docs.docker.com/engine/install/"
    exit;
fi

### VARIABLES
PORT=5000
COLOR_CYAN="\e[36m"
COLOR_ALERT="\e[33m"
COLOR_DEFAULT="\e[0m"
NAME_IMAGE=pokeapi:1.0.0
NAME_CONTAINER=pokepy

echo -e "${COLOR_CYAN}Iniciamos haciendo login a dockerhub.${COLOR_DEFAULT}"
### LOGIN DOCKER HUB
sleep 1
echo -e "${COLOR_ALERT}Ingresar su usuario de docker hub${COLOR_DEFAULT}"
read USERNAME
echo -e "${COLOR_ALERT}Ingresar su contraseña de docker hub${COLOR_DEFAULT}"
read -s -p "" PASSWORD
echo "$PASSWORD" | docker login --username $USERNAME --password-stdin

### IMAGES
echo -e "${COLOR_CYAN}Creamos la imagen.${COLOR_DEFAULT}"

# Validamos si la imagen ya existe.
if docker ps --format "{{.Image}}" | grep -q "$NAME_IMAGE"; then
    docker rm -f $NAME_CONTAINER
    docker rmi $NAME_IMAGE
fi

# Creamos la imagen a partir del Dockerfile
docker build . -t $USERNAME/$NAME_IMAGE -f Dockerfile
sleep 1
# Listamos las imagenes
echo -e "${COLOR_CYAN}Listamos las imagenes.${COLOR_DEFAULT}"
docker images

echo -e "${COLOR_CYAN}Creanos el contenedor a partir de la nueva imagen.${COLOR_DEFAULT}"

sleep 1
# Creamos el contenedor
docker run -d --name $NAME_CONTAINER -p $PORT:8000 $USERNAME/$NAME_IMAGE

echo -e "${COLOR_CYAN}En el browser ingresamos http://localhost:$PORT
Para poder ver que el contenedor se inicio correctamente.${COLOR_DEFAULT}"

sleep 2
### PUBLICAMOS LA IMAGENE
echo -e "${COLOR_CYAN}Publicamos la imagene...${COLOR_DEFAULT}"
docker push $USERNAME/$NAME_IMAGE
sleep 40
### ELIMINAMOS CONTENEDORES E IMAGENES
echo -e "${COLOR_CYAN}Eliminamos todos los contenedores${COLOR_DEFAULT}"
docker rm -f $(docker ps -aq)
echo -e "${COLOR_CYAN}Eliminamos todas las imagenes${COLOR_DEFAULT}"
docker rmi -f $(docker images -aq)
docker logout $USERNAME

#!/bin/bash

if ! which jq >/dev/null 2>&1; then
    echo "jq no está instalado. Instale e intente nuevametne"
    exit;
fi

if [ ! -f /etc/init.d/docker ]; then
    echo "Docker no está instalado. https://docs.docker.com/engine/install/"
    exit;
fi

PORT=5050
COLOR_CYAN="\e[36m"
COLOR_ALERT="\e[33m"
COLOR_DEFAULT="\e[0m"
NAME_IMAGE=simple-nginx:new
NAME_CONTAINER=mynginx

# Validamos si la imagen ya existe.
if docker ps --format "{{.Image}}" | grep -q "$NAME_IMAGE"; then
    docker rm -f $NAME_CONTAINER
    docker rmi $NAME_IMAGE
fi

# Creamos la imagen a partir del Dockerfile
docker build . -t $NAME_IMAGE

# Creamos el contenedor
docker run -d --name $NAME_CONTAINER -p $PORT:80 $NAME_IMAGE

# Obtener la salida del comando docker inspect
LAYERS=$(docker inspect --format='{{json .RootFS.Layers}}' $NAME_IMAGE)

echo -e "${COLOR_CYAN}$LAYERS${COLOR_DEFAULT}"
# Contamos los layers
count=$(echo "$LAYERS" | jq length)

echo -e "${COLOR_ALERT}La imagen $NAME_IMAGE tiene $count layers.${COLOR_DEFAULT}"

echo -e "${COLOR_CYAN}En el browser ingresamos http://localhost:$PORT
Para poder ingresar al contenedor de nginx ejecutar el comando:
docker exec -it $NAME_CONTAINER sh
despues de ingresar puedes usar los comandos sh.${COLOR_DEFAULT}"

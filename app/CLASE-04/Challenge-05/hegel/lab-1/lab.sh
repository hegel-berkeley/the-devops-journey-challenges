#!/bin/bash

if [ ! -f /etc/init.d/docker ]; then
    echo "Docker no está instalado. https://docs.docker.com/engine/install/"
    exit;
fi

PORT=8000
COLOR_CYAN="\e[36m"
COLOR_ALERT="\e[33m"
COLOR_DEFAULT="\e[0m"
NAME_IMAGE=simple-api:new
NAME_CONTAINER_API=api

NAME_IMAGE_CONSUMER=simple-consumer:new
NAME_CONTAINER_CONSUMER=consumer

### API
echo -e "${COLOR_CYAN}Creamos la imagen y contenedor del api.${COLOR_DEFAULT}"
# Validamos si la imagen ya existe.
if docker ps --format "{{.Image}}" | grep -q "$NAME_IMAGE"; then
    docker rm -f $NAME_CONTAINER_API
    docker rmi $NAME_IMAGE
fi

# Creamos la imagen a partir del Dockerfile
docker build . -t $NAME_IMAGE -f Dockerfile-api

# Creamos el contenedor
docker run -d --name $NAME_CONTAINER_API -p $PORT:8000 $NAME_IMAGE
IP_ADDRESS_API=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$NAME_CONTAINER_API")
echo -e "${COLOR_CYAN}Verificamos http://localhost:$PORT ${COLOR_DEFAULT}"
sleep 1
CONTENT=$(curl localhost:$PORT)
echo -e "${COLOR_ALERT}$CONTENT${CONTENT}"
sleep 1

### CONSUMER
echo -e "${COLOR_CYAN}Creamos la imagen y contenedor del consumer.${COLOR_DEFAULT}"

# Validamos si la imagen ya existe.
if docker ps --format "{{.Image}}" | grep -q "$NAME_IMAGE_CONSUMER"; then
    docker rm -f $NAME_CONTAINER_CONSUMER
    docker rmi $NAME_IMAGE_CONSUMER
fi

# Creamos la imagen a partir del Dockerfile
docker build . -t $NAME_IMAGE_CONSUMER -f Dockerfile-consumer

# Creamos el contenedor
docker run -d --name $NAME_CONTAINER_CONSUMER -e LOCAL=true -e PYTHONUNBUFFERED="1" --add-host service-flask-app:$IP_ADDRESS_API $NAME_IMAGE_CONSUMER
echo -e "${COLOR_CYAN}Esperamos para verificar...${COLOR_DEFAULT}"
sleep 3
docker logs $NAME_CONTAINER_CONSUMER

echo -e "${COLOR_CYAN}En el browser ingresamos http://localhost:$PORT
Para poder ingresar al contenedor de nginx ejecutar el comando:
docker exec -it $NAME_CONTAINER sh
despues de ingresar puedes usar los comandos sh.${COLOR_DEFAULT}"

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
echo -e "${COLOR_ALERT}$CONTENT${COLOR_DEFAULT}"
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

### LOGIN DOCKER HUB
sleep 1
echo -e "${COLOR_ALERT}Ingresar su usuario de docker hub${COLOR_DEFAULT}"
read USERNAME
echo -e "${COLOR_ALERT}Ingresar su contraseña de docker hub${COLOR_DEFAULT}"
read -s -p "" PASSWORD

echo $PASSWORD | docker login --username $USERNAME --password-stdin

### CREAMOS LOS TAGS
echo -e "${COLOR_CYAN}Creamos los tag de las imagenes...${COLOR_DEFAULT}"
docker tag $NAME_IMAGE $USERNAME/$NAME_IMAGE
docker tag $NAME_IMAGE_CONSUMER $USERNAME/$NAME_IMAGE_CONSUMER

### PUBLICAMOS LAS IMAGENES
echo -e "${COLOR_CYAN}Publicamos las imagenes...${COLOR_DEFAULT}"
docker push $USERNAME/$NAME_IMAGE
docker push $USERNAME/$NAME_IMAGE_CONSUMER

### ELIMINAMOS CONTENEDORES E IMAGENES
echo -e "${COLOR_CYAN}Eliminamos todos los contenedores${COLOR_DEFAULT}"
docker rm -f $(docker ps -aq)
echo -e "${COLOR_CYAN}Eliminamos todos las imagenes${COLOR_DEFAULT}"
docker rmi -f $(docker images -aq)

### VALIDAMOS SI EXISTE EL ARCHIVO DOCKER-COMPOSE
if [ ! -f ./docker-compose.yml ]; then
    echo "No existe el archivo docker-compose.yml"
    exit;
fi

if ! command -v docker-compose >/dev/null 2>&1; then
    echo "Docker Compose no está instalado."
    exit;
fi

echo -e "${COLOR_CYAN}Ejecutamos el comando docker-compose up -d${COLOR_DEFAULT}"
docker-compose up -d
echo -e "${COLOR_CYAN}Verificamos que los contenedores esten corriendo de forma correcta${COLOR_DEFAULT}"
CONTENT_CURL=$(curl localhost:$PORT)
echo -e "${COLOR_ALERT}$CONTENT_CURL${COLOR_DEFAULT}"
sleep 3
docker logs $NAME_CONTAINER_CONSUMER
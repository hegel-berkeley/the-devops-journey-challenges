#!/bin/bash

if [ ! -f /etc/init.d/docker ]; then
    echo "Docker no está instalado. https://docs.docker.com/engine/install/"
    exit;
fi

### VARIABLES
COLOR_CYAN="\e[36m"
COLOR_DEFAULT="\e[0m"

API_NAME_IMAGE=api:1.0.0
API_NAME_CONTAINER=api

NGINX_PORT=8080
NGINX_NAME_IMAGE=nginx:1.0.0
NGINX_NAME_CONTAINER=nginx

############# API #########################################################
echo -e "${COLOR_CYAN}Creamos la imagen del api.${COLOR_DEFAULT}"
# Validamos si la imagen del app ya existe.
if docker ps --format "{{.Image}}" | grep -q "$API_NAME_IMAGE"; then
    docker rm -f $API_NAME_CONTAINER
    docker rmi $API_NAME_IMAGE
fi

# Creamos la imagen a partir del Dockerfile-api
docker build . -t $API_NAME_IMAGE -f Dockerfile-api
sleep 1

# Listamos las imagenes creadas
echo -e "${COLOR_CYAN}Listamos las imagenes.${COLOR_DEFAULT}"
docker images


############# NGINX #########################################################
echo -e "${COLOR_CYAN}Creamos la imagen del app vote.${COLOR_DEFAULT}"
# Validamos si la imagen del app ya existe.
if docker ps --format "{{.Image}}" | grep -q "$NGINX_NAME_IMAGE"; then
    docker rm -f $NGINX_NAME_CONTAINER
    docker rmi $NGINX_NAME_IMAGE
fi

# Creamos la imagen a partir del Dockerfile-vote
docker build . -t $NGINX_NAME_IMAGE -f Dockerfile-nginx
sleep 1

# Listamos las imagenes creadas
echo -e "${COLOR_CYAN}Listamos las imagenes.${COLOR_DEFAULT}"
docker images

### VALIDAMOS SI EXISTE EL ARCHIVO DOCKER-COMPOSE.YML Y SI ESTA INSTALADO DOCKER-COMPOSE
sleep 1
if [ ! -f ./docker-compose.yml ]; then
    echo "No existe el archivo docker-compose.yml"
    exit;
fi

if ! command -v docker-compose >/dev/null 2>&1; then
    echo "Docker Compose no está instalado."
    exit;
fi
############# EJECUTAMOS DOCKER_COMPOSE UP ######################################
echo -e "${COLOR_CYAN}Ejecutamos el comando docker-compose up -d donde usamos la imagen local creada${COLOR_DEFAULT}"
docker-compose up -d

sleep 1
echo -e "${COLOR_CYAN}Verificamos que los contenedores esten corriendo de forma correcta${COLOR_DEFAULT}"
docker ps

############# ELIMINAMOS CONTENEDORES E IMAGENES ######################################
echo -e "${COLOR_CYAN}Dentro de 240 segundos se eliminaran los contenedores e imagenes${COLOR_DEFAULT}"
echo -e "${COLOR_CYAN}ingrese a http://localhost:$NGINX_PORT ${COLOR_DEFAULT}"
echo -e "${COLOR_CYAN}ingrese a http://localhost:$NGINX_PORT/user?name=demo&lastname=test para insertar un usuario ${COLOR_DEFAULT}"
echo -e "${COLOR_CYAN}ingrese a http://localhost:$NGINX_PORT/users para listar los usuarios ${COLOR_DEFAULT}"
sleep 240
echo -e "${COLOR_CYAN}Se procede a eliminar los contenedores e imagenes${COLOR_DEFAULT}"
docker-compose down -v --rmi all

#!/bin/bash

if [ ! -f /etc/init.d/docker ]; then
    echo "Docker no está instalado. https://docs.docker.com/engine/install/"
    exit;
fi

### VARIABLES
COLOR_CYAN="\e[36m"
COLOR_DEFAULT="\e[0m"
APP_PORT=8080
APP_NAME_IMAGE=app_ecommerce:1.0.0
APP_NAME_CONTAINER=app_ecommerce

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

############# FRONTEND #########################################################
echo -e "${COLOR_CYAN}Creamos la imagen del app ecommerce.${COLOR_DEFAULT}"
# Validamos si la imagen del app ya existe.
if docker ps --format "{{.Image}}" | grep -q "$APP_NAME_IMAGE"; then
    docker rm -f $APP_NAME_CONTAINER
    docker rmi $APP_NAME_IMAGE
fi

# Creamos la imagen a partir del Dockerfile
docker build . -t $APP_NAME_IMAGE -f Dockerfile-app
sleep 1

# Listamos las imagenes creadas
echo -e "${COLOR_CYAN}Listamos las imagenes.${COLOR_DEFAULT}"
docker images

############# EJECUTAMOS DOCKER_COMPOSE UP ######################################
echo -e "${COLOR_CYAN}Ejecutamos el comando docker-compose up -d donde usamos la imagen local creada${COLOR_DEFAULT}"
docker-compose up -d

############# EJECUTAMOS DOCKER_COMPOSE UP ######################################
sleep 1
echo -e "${COLOR_CYAN}Verificamos que los contenedores esten corriendo de forma correcta${COLOR_DEFAULT}"
docker ps

############# ELIMINAMOS CONTENEDORES E IMAGENES ######################################
echo -e "${COLOR_CYAN}Dentro de 240 segundos se eliminaran los contenedores e imagenes${COLOR_DEFAULT}"
echo -e "${COLOR_CYAN}ingrese a http://localhost:$APP_PORT ${COLOR_DEFAULT}"
sleep 240
echo -e "${COLOR_CYAN}Se procede a eliminar los contenedores e imagenes${COLOR_DEFAULT}"
docker-compose down -v --rmi all

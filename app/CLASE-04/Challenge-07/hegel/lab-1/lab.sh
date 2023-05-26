#!/bin/bash

if [ ! -f /etc/init.d/docker ]; then
    echo "Docker no está instalado. https://docs.docker.com/engine/install/"
    exit;
fi

### VARIABLES
COLOR_CYAN="\e[36m"
COLOR_ALERT="\e[33m"
COLOR_DEFAULT="\e[0m"
BACKEND_PORT=8000
FRONTEND_PORT=3000
BACKEND_NAME_IMAGE=backend_pokemon:1.0.0
BACKEND_NAME_CONTAINER=backend_pokemon
FRONTEND_NAME_IMAGE=frontend_pokemon:1.0.0
FRONTEND_NAME_CONTAINER=frontend_pokemon

############# LOGIN DOCKER HUB ########################################################
echo -e "${COLOR_CYAN}Iniciamos haciendo login a dockerhub.${COLOR_DEFAULT}"
sleep 1
echo -e "${COLOR_ALERT}Ingresar su usuario de docker hub${COLOR_DEFAULT}"
read USERNAME
echo -e "${COLOR_ALERT}Ingresar su contraseña de docker hub${COLOR_DEFAULT}"
read -s -p "" PASSWORD
echo "$PASSWORD" | docker login --username $USERNAME --password-stdin

############# BACKEND ########################################################
echo -e "${COLOR_CYAN}Creamos la imagen backend.${COLOR_DEFAULT}"

# Validamos si la imagen del backend ya existe.
if docker ps --format "{{.Image}}" | grep -q "$BACKEND_NAME_IMAGE"; then
    docker rm -f $BACKEND_NAME_CONTAINER
    docker rmi $BACKEND_NAME_IMAGE
fi

# Creamos la imagen a partir del Dockerfile
docker build . -t $BACKEND_NAME_IMAGE -f Dockerfile-backend
sleep 1

# Listamos las imagenes creadas
echo -e "${COLOR_CYAN}Listamos las imagenes.${COLOR_DEFAULT}"
docker images

sleep 1
# Creamos el contenedor del backend
docker run -d --name $BACKEND_NAME_CONTAINER -p $BACKEND_PORT:8000 $BACKEND_NAME_IMAGE
# Listamos el contenedor creado
echo -e "${COLOR_CYAN}Listamos el contenedor.${COLOR_DEFAULT}"
docker ps

############# FRONTEND #########################################################
echo -e "${COLOR_CYAN}Creamos la imagen frontend.${COLOR_DEFAULT}"
# Validamos si la imagen del backend ya existe.
if docker ps --format "{{.Image}}" | grep -q "$FRONTEND_NAME_IMAGE"; then
    docker rm -f $FRONTEND_NAME_CONTAINER
    docker rmi $FRONTEND_NAME_IMAGE
fi

# Creamos la imagen a partir del Dockerfile
docker build . -t $FRONTEND_NAME_IMAGE -f Dockerfile-frontend
sleep 1

# Listamos las imagenes creadas
echo -e "${COLOR_CYAN}Listamos las imagenes.${COLOR_DEFAULT}"
docker images

sleep 1
# Creamos el contenedor del backend
docker run -d --name $FRONTEND_NAME_CONTAINER -p $FRONTEND_PORT:3000 $FRONTEND_NAME_IMAGE
# Listamos el contenedor creado
echo -e "${COLOR_CYAN}Listamos el contenedor.${COLOR_DEFAULT}"
docker ps

############# PREPARAR LAS IMAGENES PARA PUBLICARLAS ##############################
sleep 1
### CREAMOS LOS TAGS DE LAS IMAGENES
echo -e "${COLOR_CYAN}Creamos los tag de las imagenes...${COLOR_DEFAULT}"
docker tag $BACKEND_NAME_IMAGE $USERNAME/$BACKEND_NAME_IMAGE
docker tag $FRONTEND_NAME_IMAGE $USERNAME/$FRONTEND_NAME_IMAGE

############# PUBLICAMOS LAS IMAGENES ############################################
sleep 1
echo -e "${COLOR_CYAN}Publicamos las imagenes...${COLOR_DEFAULT}"
docker push $USERNAME/$BACKEND_NAME_IMAGE
docker push $USERNAME/$FRONTEND_NAME_IMAGE

############# ELIMINAMOS TODOS CONTENEDORES E IMAGENES LOCALES ###################
sleep 1
echo -e "${COLOR_CYAN}Eliminamos todos los contenedores y las imagenes locales${COLOR_DEFAULT}"
docker rm -f $(docker ps -aq)
docker rmi -f $(docker images -aq)

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
echo -e "${COLOR_CYAN}Ejecutamos el comando docker-compose up -d${COLOR_DEFAULT}"
docker-compose up -d

############# EJECUTAMOS DOCKER_COMPOSE UP ######################################
sleep 1
echo -e "${COLOR_CYAN}Verificamos que los contenedores esten corriendo de forma correcta${COLOR_DEFAULT}"
docker ps

############# ELIMINAMOS CONTENEDORES E IMAGENES ######################################
echo -e "${COLOR_CYAN}Dentro de 120 segundos se eliminaran los contenedores e imagenes${COLOR_DEFAULT}"
sleep 120

docker rm -f $(docker ps -aq)
docker rmi -f $(docker images -aq)
docker logout $USERNAME

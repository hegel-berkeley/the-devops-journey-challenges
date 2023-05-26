#!/bin/bash

if [ ! -f /etc/init.d/docker ]; then
    echo "Docker no está instalado. https://docs.docker.com/engine/install/"
    exit;
fi

### VARIABLES
COLOR_CYAN="\e[36m"
COLOR_ALERT="\e[33m"
COLOR_DEFAULT="\e[0m"
FRONTEND_PORT=8080
FRONTEND_NAME_IMAGE=app_redis:1.0.0
FRONTEND_NAME_CONTAINER=app_redis

############# LOGIN DOCKER HUB ########################################################
echo -e "${COLOR_CYAN}Iniciamos haciendo login a dockerhub.${COLOR_DEFAULT}"
sleep 1
echo -e "${COLOR_ALERT}Ingresar su usuario de docker hub${COLOR_DEFAULT}"
read USERNAME
echo -e "${COLOR_ALERT}Ingresar su contraseña de docker hub${COLOR_DEFAULT}"
read -s -p "" PASSWORD
echo "$PASSWORD" | docker login --username $USERNAME --password-stdin

############# FRONTEND #########################################################
echo -e "${COLOR_CYAN}Creamos la imagen del app.${COLOR_DEFAULT}"
# Validamos si la imagen del app ya existe.
if docker ps --format "{{.Image}}" | grep -q "$FRONTEND_NAME_IMAGE"; then
    docker rm -f $FRONTEND_NAME_CONTAINER redis
    docker rmi $FRONTEND_NAME_IMAGE redis
fi

# Creamos la imagen a partir del Dockerfile

# Verificamos que tiene una dependencia de redis.
docker pull redis
docker run -d --name redis -p 6379:6379 redis
docker build . -t $FRONTEND_NAME_IMAGE -f Dockerfile-app
sleep 1

# Listamos las imagenes creadas
echo -e "${COLOR_CYAN}Listamos las imagenes.${COLOR_DEFAULT}"
docker images

sleep 1
# Creamos el contenedor del app
docker run -d --name $FRONTEND_NAME_CONTAINER -p $FRONTEND_PORT:80 --link redis $FRONTEND_NAME_IMAGE
# Listamos el contenedor creado
echo -e "${COLOR_CYAN}Listamos el contenedor.${COLOR_DEFAULT}"
docker ps

echo -e "${COLOR_CYAN}Tiene 60 segundos para probar ingresando a http://localhost:$FRONTEND_PORT ${COLOR_DEFAULT}"

############# PREPARAR LA IMAGEN PARA PUBLICARLA ##############################
sleep 60
### CREAMOS LOS TAGS DE LA IMAGEN
echo -e "${COLOR_CYAN}Creamos los tag de la imagen...${COLOR_DEFAULT}"
docker tag $FRONTEND_NAME_IMAGE $USERNAME/$FRONTEND_NAME_IMAGE

############# PUBLICAMOS LA IMAGEN ############################################
sleep 1
echo -e "${COLOR_CYAN}Publicamos la imagen...${COLOR_DEFAULT}"
docker push $USERNAME/$FRONTEND_NAME_IMAGE

############# ELIMINAMOS EL CONTENEDOR E IMAGEN LOCALES ###################
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
echo -e "${COLOR_CYAN}Dentro de 240 segundos se eliminaran los contenedores e imagenes${COLOR_DEFAULT}"
echo -e "${COLOR_CYAN}ingrese a http://localhost:$FRONTEND_PORT ${COLOR_DEFAULT}"
sleep 240
echo -e "${COLOR_CYAN}Se procede a eliminar los contenedores e imagenes${COLOR_DEFAULT}"
docker rm -f $(docker ps -aq)
docker rmi -f $(docker images -aq)
docker logout $USERNAME

#!/bin/bash

if [ ! -f /etc/init.d/docker ]; then
    echo "Docker no está instalado. https://docs.docker.com/engine/install/"
    exit;
fi

### VARIABLES
COLOR_CYAN="\e[36m"
COLOR_DEFAULT="\e[0m"
VOTE_PORT=5000
VOTE_NAME_IMAGE=vote:1.0.0
VOTE_NAME_CONTAINER=vote

RESULT_PORT=8080
RESULT_NAME_IMAGE=result:1.0.0
RESULT_NAME_CONTAINER=result

WORKER_NAME_IMAGE=worker:1.0.0
WORKER_NAME_CONTAINER=worker

############# WORKER #########################################################
echo -e "${COLOR_CYAN}Creamos la imagen del app worker.${COLOR_DEFAULT}"
# Validamos si la imagen del app ya existe.
if docker ps --format "{{.Image}}" | grep -q "$WORKER_NAME_IMAGE"; then
    docker rm -f $WORKER_NAME_CONTAINER
    docker rmi $WORKER_NAME_IMAGE
fi

# Creamos la imagen a partir del Dockerfile-worker
docker build . -t $WORKER_NAME_IMAGE -f Dockerfile-worker
sleep 1

# Listamos las imagenes creadas
echo -e "${COLOR_CYAN}Listamos las imagenes.${COLOR_DEFAULT}"
docker images


############# VOTE #########################################################
echo -e "${COLOR_CYAN}Creamos la imagen del app vote.${COLOR_DEFAULT}"
# Validamos si la imagen del app ya existe.
if docker ps --format "{{.Image}}" | grep -q "$VOTE_NAME_IMAGE"; then
    docker rm -f $VOTE_NAME_CONTAINER
    docker rmi $VOTE_NAME_IMAGE
fi

# Creamos la imagen a partir del Dockerfile-vote
docker build . -t $VOTE_NAME_IMAGE -f Dockerfile-vote
sleep 1

# Listamos las imagenes creadas
echo -e "${COLOR_CYAN}Listamos las imagenes.${COLOR_DEFAULT}"
docker images


############# RESULT #########################################################
echo -e "${COLOR_CYAN}Creamos la imagen del app result.${COLOR_DEFAULT}"
# Validamos si la imagen del app ya existe.
if docker ps --format "{{.Image}}" | grep -q "$RESULT_NAME_IMAGE"; then
    docker rm -f $RESULT_NAME_CONTAINER
    docker rmi $RESULT_NAME_IMAGE
fi

# Creamos la imagen a partir del Dockerfile-result
docker build . -t $RESULT_NAME_IMAGE -f Dockerfile-result
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
echo -e "${COLOR_CYAN}Dentro de 600 segundos se eliminaran los contenedores e imagenes${COLOR_DEFAULT}"
echo -e "${COLOR_CYAN}ingrese a http://localhost:$VOTE_PORT para ver votos ${COLOR_DEFAULT}"
echo -e "${COLOR_CYAN}ingrese a http://localhost:$RESULT_PORT para ver el resultado${COLOR_DEFAULT}"
sleep 600
echo -e "${COLOR_CYAN}Se procede a eliminar los contenedores e imagenes${COLOR_DEFAULT}"
docker-compose down -v --rmi all

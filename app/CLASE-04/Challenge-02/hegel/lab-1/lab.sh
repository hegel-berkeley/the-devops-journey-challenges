#!/bin/bash

if [ ! -f /etc/init.d/docker ]; then
    echo "Docker no está instalado. https://docs.docker.com/engine/install/"
    exit;
fi

PORT=27017
COLOR_CYAN="\e[36m"
COLOR_DEFAULT="\e[0m"
NAME_CONTAINER_MONGO=m1

if ! docker ps --format "{{.Names}}" | grep -q "$NAME_CONTAINER_MONGO"; then
    docker run -d -p $PORT:27017 --name=$NAME_CONTAINER_MONGO -v "$PWD/myapp":/myapp mongo
    docker exec -it $NAME_CONTAINER_MONGO bash -c "apt-get update && apt-get install -y python3 python3-pip python3.8-dev; pip3 install pymongo; python3 myapp/populate.py; python3 /myapp/find.py"
fi
echo "${COLOR_CYAN}
Para poder ingresar al contenedor de la base de datos ejecutar el comando:
docker exec -it $NAME_CONTAINER_MONGO /bin/bash
luego puedes conectarte a MongoDB por medio del comando mongosh.${COLOR_DEFAULT}"

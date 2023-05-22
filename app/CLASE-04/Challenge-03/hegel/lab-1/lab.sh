#!/bin/bash

if [ ! -f /etc/init.d/docker ]; then
    echo "Docker no está instalado. https://docs.docker.com/engine/install/"
    exit;
fi

PORT=9999
COLOR_CYAN="\e[36m"
COLOR_DEFAULT="\e[0m"
NAME_CONTAINER=bootcamp-web
PATH_DIRECTORY=/usr/share/nginx/html

if ! docker ps --format "{{.Names}}" | grep -q "$NAME_CONTAINER"; then
    docker run -d -p $PORT:80 --name=$NAME_CONTAINER nginx:alpine3.17-slim
fi
docker cp "$PWD/web/." $NAME_CONTAINER:$PATH_DIRECTORY/.
docker exec -it $NAME_CONTAINER sh -c "cd $PATH_DIRECTORY; ls -la"

echo -e "${COLOR_CYAN}
Para poder ingresar al contenedor de nginx ejecutar el comando:
docker exec -it $NAME_CONTAINER sh
despues de ingresar puedes usar los comandos sh.${COLOR_DEFAULT}"

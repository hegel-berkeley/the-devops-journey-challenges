#!/bin/bash

if [ ! -f /etc/init.d/docker ]; then
    echo "Docker no está instalado. https://docs.docker.com/engine/install/"
    exit;
fi

PORT=3306
PASSWORD=123456
COLOR_ERROR="\e[31m"
COLOR_ALERT="\e[33m" 
COLOR_CYAN="\e[36m"
COLOR_DEFAULT="\e[0m"
NAME_CONTAINER_DB=db
NAME_CONTAINER_PHPMYADMIN=phpmyadmin

if netstat -tuln | grep ":$PORT\b" >/dev/null; then
    echo "${COLOR_ERROR}El puerto $PORT está ocupado, se cambia el puerto al 3307"
    PORT=3307
fi

if ! docker ps --format "{{.Names}}" | grep -q "$CONTAINER_NAME"; then
    docker run --name=$NAME_CONTAINER_DB -p $PORT:3306 -e MYSQL_ROOT_PASSWORD=$PASSWORD -d mysql:8
fi

echo "${COLOR_CYAN}
Para poder ingresar al contenedor de la base de datos ejecutar el comando:
docker exec -it db /bin/bash
Para poder ingresar al MYSQL del contene ejecutar el comando:
mysql -u root -p $PASSWORD${COLOR_DEFAULT}"

if ! docker ps --format "{{.Names}}" | grep -q "$NAME_CONTAINER_PHPMYADMIN"; then
    docker run --name=$NAME_CONTAINER_PHPMYADMIN -p 82:80 --link $NAME_CONTAINER_DB:$NAME_CONTAINER_DB -d phpmyadmin
fi
echo "${COLOR_ALERT}
Abrir http://localhost:82/ en tu explorador
Usuario: ${COLOR_CYAN}root${COLOR_ALERT}
Password: ${COLOR_CYAN}$PASSWORD${COLOR_DEFAULT}
"
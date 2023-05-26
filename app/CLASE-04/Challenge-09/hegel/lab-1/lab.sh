#!/bin/bash
### VARIABLES
COLOR_CYAN="\e[36m"
COLOR_ALERT="\e[33m"
COLOR_DEFAULT="\e[0m"

############# VALIDAR SI ESTA INSTALADO GIT ########################################################
if ! command -v git >/dev/null 2>&1; then
    echo "Git no está instalado. https://git-scm.com/"
    exit;
fi
############# VALIDAR SI ESTAS LOGUEADO EN GITHUB ##################################################
if ! git config user.name >/dev/null 2>&1; then
    echo "Estás logueado en GitHub."
    echo -e "${COLOR_ALERT}Ingresar su usuario de github${COLOR_DEFAULT}"
    read USERNAME
    git config --global user.name "$USERNAME"
    echo -e "${COLOR_ALERT}Ingresar su email de github${COLOR_DEFAULT}"
    read EMAIL
    git config --global user.email "$EMAIL"
fi
############# VALIDAR SI ESTA INSTALADO DOCKER ####################################################
if [ ! -f /etc/init.d/docker ]; then
    echo "Docker no está instalado. https://docs.docker.com/engine/install/"
    exit;
fi
### VALIDAMOS SI EXISTE EL ARCHIVO DOCKER-COMPOSE.YML Y SI ESTA INSTALADO DOCKER-COMPOSE
if ! command -v docker-compose >/dev/null 2>&1; then
    echo "Docker Compose no está instalado."
    exit;
fi

sleep 1
echo -e "${COLOR_CYAN}Antes de clonar se tiene que hacer la configuracion del uso SSH KEY https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent.${COLOR_DEFAULT}"
sleep 2
echo -e "${COLOR_CYAN}Iniciamos la clonacion del repositorio https://github.com/wodby/docker4drupal.${COLOR_DEFAULT}"
sleep 1
git clone git@github.com:wodby/docker4drupal.git
echo -e "${COLOR_CYAN}Despues de clonar ingresama al directorio docker4drupal.${COLOR_DEFAULT}"
sleep 1
cd ./docker4drupal
echo -e "${COLOR_CYAN}Despues de clonar ingresama al directorio docker4drupal.${COLOR_DEFAULT}"
sleep 1
### VALIDAMOS SI EXISTE EL ARCHIVO DOCKER-COMPOSE.YML
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

# Listamos el contenedor creado
echo -e "${COLOR_CYAN}Listamos los contenedores creados.${COLOR_DEFAULT}"
docker ps

# Listamos las imagenes creadas
echo -e "${COLOR_CYAN}Listamos las imagenes.${COLOR_DEFAULT}"
docker images

# Ingresamos al contenedor de drupal para dar los permisos necesarios
echo -e "${COLOR_CYAN}Ingresamos al contenedor de nginx para dar los permisos al archivo settings.php.${COLOR_DEFAULT}"
echo -e "${COLOR_CYAN}El nombre del contenedor es la concatenacion  de PROJECT_NAME que se encuentra en docker4drupal/.env y el nombre del servidor web ${COLOR_DEFAULT}"
sleep 2
docker exec -it my_drupal10_project_nginx bash -c "chmod 644 /var/www/html/web/sites/default/settings.php"

############# ELIMINAMOS CONTENEDORES E IMAGENES ######################################
echo -e "${COLOR_CYAN}Dentro de 480 segundos se eliminaran los contenedores e imagenes${COLOR_DEFAULT}"
echo -e "${COLOR_CYAN}ingrese a http://drupal.docker.localhost:8000 ${COLOR_DEFAULT}"
sleep 480
echo -e "${COLOR_CYAN}Se procede a eliminar los contenedores e imagenes${COLOR_DEFAULT}"
docker rm -f $(docker ps -aq)
docker rmi -f $(docker images -aq)
docker volume rm -f $(docker volume ls -q)

echo -e "${COLOR_CYAN}Eliminamos el directorio clonado${COLOR_DEFAULT}"
cd ../
rm -rf ./docker4drupal
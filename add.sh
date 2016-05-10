#!/bin/bash

#On récupère le nombre de noeuds
docker ps -f "ancestor=docker_node" -q > tmp.txt
compteur=$(wc -l tmp.txt)
compteur="$(echo $compteur | head -c 1)"

#On crée un nouveau noeud
compteur=$(($compteur+1))
docker-compose scale node=$compteur

#On crée le nouveau fichier nginx.conf
mv ./nginx/nginx.conf ./new.conf
sed -i '' '9 i\
server docker_node_'$compteur':8080 weight=10 max_fails=3 fail_timeout=30s;
' new.conf
mv ./new.conf ./nginx/nginx.conf 

#On le copie dans Nginx et on redémarre le conteneur
docker cp ./nginx/nginx.conf $(docker ps -f "ancestor=docker_nginx" -q ):/etc/nginx/
docker-compose build
docker-compose up &

#on supprime les fichiers temporaires 
rm tmp.txt
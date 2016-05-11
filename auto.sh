#!/bin/bash

#on récupère l'ID du premier noeud
idNoeud=$(docker ps -f "ancestor=docker_node" -q)

#On boucle à l'infinie
while true; do

#On récupère l'ID du dernier noeud démarré
docker stats --no-stream $idNoeud > log.txt

#On lit le % d'utiliation CPU
grep -o -h '[0-9 ][0-9]\.[0-9][0-9]' log.txt > tmp.txt
usage=$(head -n 1 tmp.txt)
usage=$(echo $usage | cut -f1 -d.)
echo "Usage : " $usage "%"

#On récupère le nombre de noeuds
docker ps -f "ancestor=docker_node" -q > tmp.txt
compteur=$(wc -l tmp.txt)
compteur="$(echo $compteur | head -c 1)"
echo "Nb de noeuds : " $compteur

#Si charge est inférieur à 20% et s'il y a plus de 1 noeud, alors on supprime un noeud
if [ $compteur -gt 1 ]
	then
	if [ $usage -lt 20 ]
		then
	./remove.sh
	sleep 5
	fi
fi
#Si la charge est supérieure à 60%, alors on ajoute un noeud
if [ $usage -gt 60 ]
	then
	./add.sh
	sleep 10
fi

#On attend pour ne pas boucler trop vite et ralentir la machine
sleep 2
done
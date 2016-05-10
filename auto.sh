#!/bin/bash

#On boucle à l'infinie
while true; do

#On récupère l'ID du dernier noeud démarré
docker stats --no-stream $(docker ps -f "ancestor=docker_node" -ql) > log.txt

#On lit le % d'utiliation CPU
grep -o -h '[0-9 ][0-9]\.[0-9][0-9]' log.txt > tmp.txt
usage=$(head -n 1 tmp.txt)

#On récupère le nombre de noeuds
docker ps -f "ancestor=docker_node" -q > tmp.txt
compteur=$(wc -l tmp.txt)
compteur="$(echo $compteur | head -c 1)"

#Si charge < 20% et plus de 1 noeud, alors on supprime un noeud
if [$compteur -ht 1]
	then
	if [$usage -lt 20]
		then
	./remove.sh
	fi
fi
#Si charge > 60%, alors on ajout un noeud
if [$compteur -gt 60]
	then
	./add.sh
fi

#On attend pour ne pas boucler trop vite et ralentir la machine
sleep 2
done
Projet d'étude pratique
=======================

Installation
------------

1) Installer Docker Quickstart et VirtualBox à l'aide de Docker ToolBox disponible à cette adresse :

	https://www.docker.com/products/docker-toolbox

2) Récupérer le contenu du dépôt Github : 
	
	git clone https://github.com/kentin19/Docker

3) Démarrer Docker Quickstart

4) Se placer dans le dossier que vous venez de télécharger :

	cd $(chemin du dossier Docker)

##### Docker-machine n'est peut-être pas configuré !

Un test simple existe pour le vérifier:

	docker-machine start default
	docker ps

S'il y a un problème de daemon, faites :

	docker-machine regenerate-certs default
	eval "$(docker-machine env default)"

Premier pas
-----------

Voilà ce que nous allons faire :


![Alt Tag](https://github.com/kentin19/Docker/raw/master/ressource/img1.png)

##### N. B. Un changement majeur a eu lieu, un seul noeud est désormais démarré !

1) Démarrer tous les conteneurs à l'aide de cette commande :

	docker-compose up

2) Récupérer l'adresse IP de la machine :

	docker-machine ip default

Vous pouvez tester si cela fonctionne en rentrant l'adresse IP dans votre navigateur internet. "This page has been viewed 1 times!" doit apparaitre. Vous pouvez tester les performances de cette configuration à l'aide d'Apache Benchmark.

Benchmark
---------

### Apache Benchmark

Une première façon de tester les performances des conteneurs est d'utiliser Apache Benchmark (AB pour les intimes). Cependant, nous avons rencontré des incompatibilités entre OSX, AB et l'allocation dynamique des ressources. Nous proposons une deuxième façon d'effectuer les tests en dessous.

S'il n'est pas déjà installé, suivez cette procédure :

	apt-get update
	apt-get install apache2-utils

Une fois AB installée, vous pouvez lancer le benchmark :
	
	ab -r -n {nb total de requêtes} -c {nb de requêtes simultanées} http://{adresse ip}:80/

Suivant les capacités de votre ordinateur, les performances sont bonnes jusqu'à n requêtes simultanées. Si plus de requêtes sont lancées simultanément, alors les performances baissent grandement. Il faut utiliser la scalabilité.

### Siege Benchmark

Siege benchmark fonctionne de la même façon qu’AB. Voici comment l'installer sous OSX.

Ouvrir le terminal et récupérer la dernière version :

	curl -C - -O http://download.joedog.org/siege/siege-latest.tar.gz

Extraire l'archive .tar :

	tar -xvf siege-latest.tar.gz

Se placer dans le dossier que vous venez d'extraire :

	cd siege-{version}/

Configurer, puis installer siege :

	./configure
	make
	sudo make install

Siege a été installé dans /usr/local/bin/. Pour vérifier qu'il est bien installé, faites :

	siege

Voici une requête de base: 

	siege -c {nb de requêtes simultanées} -r {nb total de requêtes} http://{adresse ip}:80/

#### Comment avoir une idée de la charge de travail d'un conteneur ?

Il est possible de créer un log pour chaque conteneur comme ceci :
	
	docker ps
	docker stats {id conteneur} > log.txt
	
Le fichier ressemble à ça:

	CONTAINER	CPU %		MEM USAGE/LIMIT		MEM %		NET I/O
	e64a279663	0.00%		7.227 MiB/987.9 MiB	0.73%		936 B/468 B

#### Qu'est ce qu'il se passe dans un noeud ?

Des calculs (multiplications et transpositions) de grandes matrices (2000x2000) générées aléatoirement sont effectués à chaque requête. La charge porte essentiellement sur le processeur, moins de 100mo de RAM par noeud sont nécessaires. 

Scalabilité
-----------

Le principe est assez simple, on souhaite avoir des performances optimales sans gaspiller de ressources. Quand l'application est au repos (c.-à-d. sans requêtes), on laisse tourner un seul conteneur. Quand la charge augmente (c.-à-d. le nombre de requêtes simultanées augmente), on démarre suffisamment de conteneurs pour couvrir la charge.

![Alt Tag](https://github.com/kentin19/Docker/raw/master/ressource/img2.png)


### Manuel

Dans un premier temps, nous allons allouer de nouveaux conteneurs manuellement.

Il existe une commande créée par Docker:
	
	docker-compose scale node = {nb total de noeuds}

Cependant, il faut ajouter les nouveaux noeuds à la configuration de nginx pour qu'il redirige les requêtes vers eux. Nous avons crée deux script bash (add.sh et remove.sh) qui modifie en plus la configration du load balancer. 
Pour ajouter un noeud, il suffit de faire : 
	
	./add.sh

Et pour supprimer un noeud : 

	./remove.sh

### Automatique

Afin d'avoir un allocation des ressources dynamique, il est nécessaire d'automatiser l'ajout et la suppréssion de conteneurs. Nous avons fait cela avec auto.sh. Nous avons fait le choix de limiter la charge CPU de chaque noeud à 60%. Quand la charge dépasse 50%, le script ajoute un noeud. Si la charge diminue en dessous de 20% (et qu'il y a plus d'un noeud), auto.sh supprime un noeud.
Pour lancer le script, il suffit de faire : 

	./auto.sh

Quitter proprement Compose
--------------------------

Quitter proprement signifie non seulement stopper tous les conteneurs qui tournent, mais aussi les supprimer. Ces deux lignes font ça pour vous:

	docker-compose kill
	docker rm $(docker ps -a -q)

Vous pouvez aussi supprimer les images que vous n'utilisez plus ou que vous souhaitez modifier. 
	
	docker images
	docker rmi {le nom ou id des images à supprimer}
	
Ou toutes les images d'un seul coup

	docker rmi $(docker images -q)

##### Petite astuce : les deux ou trois premiers chiffres ou lettres de l'id suffisent, inutile de tout recopier

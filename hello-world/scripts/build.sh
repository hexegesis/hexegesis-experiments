#!/bin/sh

# Arrête le script dès qu'une commande échoue ou qu'une variable non définie est utilisée.
set -eu

# Calcule le chemin absolu du projet pour que le script fonctionne quel que soit
# le répertoire depuis lequel il est appelé.
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

# Le nom peut être remplacé par PS3DEV_IMAGE sans modifier le script.
ps3dev_image=${PS3DEV_IMAGE:-hexegesis-ps3dev}

# Centralise les options de construction de l'image de développement. Docker
# sélectionne automatiquement la variante adaptée à l'architecture de son moteur.
docker_build() {
    docker build \
        --progress plain \
        --tag "$ps3dev_image" \
        --file "$root/Dockerfile.ps3dev" \
        "$root"
}

# Exécute une commande avec /bin/sh -eu pour l'arrêter dès la première erreur ou
# variable non définie. Le projet est monté dans le répertoire /workspace.
docker_run() {
    docker run --rm \
        --volume "$root:/workspace" \
        --workdir /workspace \
        "$ps3dev_image" \
        /bin/sh -eu -c "$1"
}

printf "\n==> Construction de l'image de développement PS3\n"
docker_build

# Le volume est inscriptible, car make place les objets, le SELF et disc-root
# directement dans le répertoire du projet sur l'hôte.
printf "\n==> Compilation de l'application et création du répertoire de jeu\n"
docker_run '
    make clean disc VERBOSE=1
'

# xorriso copie l'arborescence déjà construite dans un système de fichiers
# ISO 9660 sans remplissage ajouté en fin d'image.
printf "\n==> Création de l'image ISO 9660\n"
docker_run '
    xorriso -as mkisofs \
        -iso-level 1 \
        -volid HXGS00001 \
        -no-pad \
        -output hello-world.iso \
        disc-root
'

# Le script de correction reçoit l'ISO par le volume et écrit uniquement les
# champs de la table de régions nécessaires à cette image non chiffrée.
printf '\n==> Écriture de la table de régions PS3\n'
docker_run 'scripts/patch-ps3-regions.sh hello-world.iso'

# Ces commandes affichent les propriétés de l'image qui vient d'être produite.
printf '\n==> Vérification du résultat\n'
docker_run '
    stat -c "image=%n" hello-world.iso
    stat -c "octets=%s" hello-world.iso
    printf "premiers-16-octets="
    od -An -tx1 -N16 hello-world.iso | tr -d " \n"
    printf "\n"
    sha256sum hello-world.iso
'

# Le dernier contrôle relit l'ISO avec xorriso et affiche tous les fichiers
# effectivement enregistrés dans son système de fichiers.
docker_run '
    xorriso \
        -indev hello-world.iso \
        -find / -type f \
        -exec lsdl
'

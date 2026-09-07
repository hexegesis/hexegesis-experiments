# Hello World PlayStation 3

Cette expérimentation construit, à partir de sources redistribuables, un programme PlayStation 3 minimal et une image disque synthétique. Elle sert d'exemple reproductible pour les articles consacrés à Hexegesis ; elle ne démontre aucune compatibilité avec une console physique ou une image commerciale.

## Prérequis

- Docker
- RPCS3

## Construction

Depuis ce répertoire, exécutez :

```sh
./scripts/build.sh
```

Le script construit l'image de développement PS3, compile `source/main.c`, crée le répertoire de jeu, forme une ISO 9660, ajoute l'intervalle de secteurs non protégés attendu par RPCS3, puis vérifie le résultat.

Les fichiers produits sont ignorés par Git et peuvent être recréés à tout moment.

## Arborescence produite

```text
disc-root/
├── PS3_DISC.SFB
└── PS3_GAME/
    ├── PARAM.SFO
    └── USRDIR/
        └── EBOOT.BIN
```

`PS3_DISC.SFB` contient uniquement la signature `.SFB`. `PARAM.SFO` décrit le jeu synthétique `HXGS00001`. `EBOOT.BIN` écrit `Bonjour depuis Hexegesis.` dans le TTY puis se termine.

## Résultat attendu

RPCS3 doit pouvoir lancer `disc-root/` puis `hello-world.iso`. Dans les deux cas, le TTY doit contenir :

```text
Bonjour depuis Hexegesis.
```

La table écrite dans la zone système décrit un unique intervalle non chiffré couvrant toute cette image synthétique. Cette expérience vise RPCS3 et ne constitue pas une recette de disque destiné à une PlayStation 3 physique.

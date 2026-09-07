# Hello World PlayStation 3

[![Construction de l'ISO](https://github.com/hexegesis/hexegesis-experiments/actions/workflows/release-hello-world.yml/badge.svg?branch=main)](https://github.com/hexegesis/hexegesis-experiments/actions/workflows/release-hello-world.yml?query=branch%3Amain)

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

## Publication avec GitHub Actions

Le badge ci-dessus indique la dernière construction du workflow sur `main`. Un tag dont le nom suit la forme `hello-world-v*` construit cette même ISO avec GitHub Actions et la joint à la GitHub Release correspondante. Le workflow appelle uniquement `./scripts/build.sh` : la procédure locale, la procédure de CI et les contrôles de structure décrits plus haut restent donc identiques.

```sh
git tag hello-world-v0.1.0
git push origin hello-world-v0.1.0
```

La release contient `hello-world.iso`. Elle identifie le commit étiqueté qui a produit cette image. La CI vérifie sa structure, mais ne démarre pas RPCS3 ; l’observation du message TTY reste une vérification manuelle décrite ci-dessous. Comme pour toute l’expérience, cette ISO synthétique vise RPCS3 et ne constitue ni une image commerciale ni un support destiné à une console PlayStation 3 physique.

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

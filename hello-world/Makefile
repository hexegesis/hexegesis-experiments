# Désactive les règles implicites fondées sur les suffixes afin que seules les
# transformations définies ici et dans ppu_rules soient utilisées.
.SUFFIXES:

# PSL1GHT fournit les règles de compilation et les chemins de la chaîne PPU.
ifeq ($(strip $(PSL1GHT)),)
$(error PSL1GHT n'est pas défini)
endif

# Noms des fichiers produits et emplacement de l'arborescence du jeu disque.
TARGET := hello-world
OUTPUT := $(CURDIR)/$(TARGET)
OFILES := source/main.o
DISC_ROOT := $(CURDIR)/disc-root
PARAM_SFO := $(DISC_ROOT)/PS3_GAME/PARAM.SFO
EBOOT_BIN := $(DISC_ROOT)/PS3_GAME/USRDIR/EBOOT.BIN
DISC_SFB := $(DISC_ROOT)/PS3_DISC.SFB

.PHONY: all disc clean

# La cible par défaut construit le SELF sans former le répertoire de jeu.
all: $(OUTPUT).self

# Le répertoire est complet lorsque son descripteur, ses métadonnées et son
# exécutable sont tous présents.
disc: $(DISC_SFB) $(PARAM_SFO) $(EBOOT_BIN)

# ppu_rules définit notamment CC, STRIP, sprxlinker, make_self et les règles qui
# transforment source/main.o en hello-world.elf puis en hello-world.self.
include $(PSL1GHT)/ppu_rules

# Le pilote GCC effectue aussi l'édition de liens. MACHDEP regroupe les options
# PPU communes de PSL1GHT et LIBPSL1GHT_INC ajoute ses en-têtes publics.
LD := $(CC)
CFLAGS := -O2 -Wall -mcpu=cell $(MACHDEP) $(LIBPSL1GHT_INC)
LDFLAGS := $(MACHDEP)

# librt relie stdout et stderr au TTY de la PS3. llv2 fournit les appels système
# de bas niveau utilisés par cette bibliothèque d'exécution.
LIBS := -lrt -llv2

# RPCS3 vérifie uniquement la signature initiale pour cet exemple minimal.
$(DISC_SFB):
	mkdir -p $(dir $@)
	printf '.SFB' > $@

# L'outil sfo convertit la description XML lisible en PARAM.SFO binaire.
$(PARAM_SFO): param-sfo.xml
	mkdir -p $(dir $@)
	sfo --fromxml $< $@

# Le SELF devient le point d'entrée attendu dans l'arborescence du jeu.
$(EBOOT_BIN): $(OUTPUT).self
	mkdir -p $(dir $@)
	cp $< $@

# Supprime uniquement les fichiers reproductibles générés par la construction.
clean: ; rm -rf build disc-root source/main.o $(OUTPUT).elf $(OUTPUT).self $(OUTPUT).fake.self $(OUTPUT).iso

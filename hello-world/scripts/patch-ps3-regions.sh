#!/bin/sh

# Arrête le script à la première erreur et refuse les variables non définies.
set -eu

# Une seule image doit être fournie afin d'éviter toute écriture ambiguë.
if [ "$#" -ne 1 ]; then
    printf 'utilisation : %s IMAGE.iso\n' "$0" >&2
    exit 2
fi

image=$1

# ISO 9660 et le lecteur PS3 de RPCS3 utilisent ici des secteurs de 2 048 octets.
sector_size=2048
size=$(stat -c %s "$image")

# Une image composée de secteurs incomplets ne permet pas de calculer une LBA finale fiable.
if [ $((size % sector_size)) -ne 0 ]; then
    printf "%s : la taille n'est pas un multiple de %s octets\n" "$image" "$sector_size" >&2
    exit 1
fi

sector_count=$((size / sector_size))

# Les seize premiers secteurs forment la zone système. Le premier descripteur
# de volume ISO 9660 doit donc pouvoir commencer au secteur suivant, la LBA 16.
if [ "$sector_count" -lt 17 ]; then
    printf "%s : l'image est trop petite pour contenir un descripteur de volume principal ISO 9660\n" "$image" >&2
    exit 1
fi

# Les sept octets attendus sont le type 1, la signature ASCII CD001 et la version 1.
pvd_header=$(od -An -tx1 -j $((16 * sector_size)) -N7 "$image" | tr -d ' \n')
if [ "$pvd_header" != 01434430303101 ]; then
    printf '%s : aucun descripteur de volume principal ISO 9660 trouvé à la LBA 16\n' "$image" >&2
    exit 1
fi

# Les LBA commencent à zéro : une image de N secteurs se termine donc à la LBA N - 1.
last_lba=$((sector_count - 1))

# La table stocke ses LBA dans des entiers non signés de 32 bits.
if [ "$last_lba" -gt 4294967295 ]; then
    printf '%s : la dernière LBA ne tient pas sur 32 bits\n' "$image" >&2
    exit 1
fi

# Encode un entier de 32 bits en quatre octets big-endian, puis l'écrit à
# l'offset demandé sans tronquer le reste de l'image.
write_be32() {
    value=$1
    offset=$2
    bytes=$(printf '\\%03o\\%03o\\%03o\\%03o' \
        $(((value >> 24) & 255)) \
        $(((value >> 16) & 255)) \
        $(((value >> 8) & 255)) \
        $((value & 255)))
    printf '%b' "$bytes" | dd of="$image" bs=1 seek="$offset" conv=notrunc status=none
}

# Un unique intervalle non protégé couvre toute l'image synthétique. Le champ
# non interprété à l'offset 4 et la première LBA à l'offset 8 valent déjà zéro
# dans la zone système créée par xorriso. Seuls le compteur et la fin changent.
write_be32 1 0
write_be32 "$last_lba" 12

printf 'nombre-intervalles-non-proteges=1\n'
printf 'derniere-lba=%s\n' "$last_lba"

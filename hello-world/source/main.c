#include <stdio.h>
#include <stdlib.h>

/*
 * Écrit une ligne sur la sortie standard. La bibliothèque librt de PSL1GHT
 * transmet cette sortie au TTY de la PS3, que RPCS3 enregistre dans son journal.
 */
int main(void)
{
    /* puts ajoute automatiquement un retour à la ligne après le message. */
    puts("Bonjour depuis Hexegesis.");

    /* Un code nul indique au système que le programme s'est terminé normalement. */
    return EXIT_SUCCESS;
}

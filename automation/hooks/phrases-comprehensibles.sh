#!/usr/bin/env bash
# Purpose : rappeler, à chaque tour, d'écrire pour un être humain.
#
#           Demande de Yann, 2026-09-22 : « fais l'effort de faire des phrases compréhensibles ».
#           Dite devant un plan juste sur le fond et pénible à lire — des phrases empilées, du
#           vocabulaire de code dans un texte destiné à décider. Un document qu'on renonce à lire ne
#           vaut rien, quelle que soit sa justesse.
#
#           POURQUOI UN RAPPEL ET NON UN CONTRÔLE. La lisibilité ne se mesure pas sans se tromper.
#           Compter les mots par phrase punirait une bonne phrase longue et laisserait passer trois
#           phrases courtes illisibles. On rappelle donc la règle à chaque tour, et on ne la police
#           pas : c'est le jugement qui écrit, pas le compteur.
#
# Usage   : hook Claude Code `UserPromptSubmit`. Ce qu'il écrit sur stdout est ajouté au contexte.
# Arguments : aucun.
# Exit codes :
#   0  -> toujours. Ce hook ne fait JAMAIS échouer un tour : il rappelle, il n'empêche rien.
set -uo pipefail

cat <<'RAPPEL'
Rappel d'écriture (hook général — s'applique à tout ce que tu rends à lire) :
• Écris pour un humain, pas pour un relecteur de code. Une idée par phrase.
• Le mot courant plutôt que le mot technique quand les deux disent la même chose.
• Un tableau plutôt qu'un paragraphe dès qu'il s'agit de comparer.
• Un terme technique nécessaire s'explique la première fois qu'il apparaît.
• Dis d'abord ce que ça change pour la personne, ensuite comment c'est fait.
RAPPEL
exit 0

#!/usr/bin/env bash
# Purpose : exiger qu'un plan soit ARCHITECTURAL **et** FONCTIONNEL, et qu'il porte au moins un
#           SCHÉMA — avant qu'il ne soit présenté à l'humain.
#
#           Demande de Yann, 2026-09-22 : « fais un hook général pour cela : 1) faire des plans
#           architecturaux et fonctionnels, 2) faire des phrases compréhensibles pour un humain ».
#           La règle 2 se rappelle (voir `phrases-comprehensibles.sh`) ; celle-ci se VÉRIFIE, parce
#           qu'elle se constate dans le fichier.
#
#           Pourquoi bloquer AVANT la présentation plutôt que reprocher après : un plan sans dessin
#           oblige le lecteur à reconstruire la forme dans sa tête, et un plan qui ne dit que la
#           mécanique laisse son lecteur sans réponse à la seule question qui l'intéresse — « qu'est-ce
#           que ça change pour moi ? ». Une fois le plan présenté, il est trop tard : on l'a lu.
#
# Usage   : hook Claude Code `PreToolUse` (matcher ExitPlanMode). Reçoit le JSON de l'appel sur stdin.
# Arguments : aucun. Le fichier de plan est cherché dans cet ordre :
#             1. $CLAUDE_PLAN_FILE, s'il est posé ;
#             2. le plan le plus RÉCEMMENT modifié de ~/.claude/plans (ou $CLAUDE_PLANS_DIR).
# Exit codes :
#   0  -> autorisé (plan conforme, OU aucun plan récent trouvé, OU échappatoire posée)
#   2  -> BLOQUÉ : le message sur stderr dit CE QUI MANQUE et comment le combler
#
# Échappatoire assumée : PLAN_SANS_SCHEMA=1 pour un plan qui n'en justifie vraiment pas (un
# renommage, une correction d'une ligne). Elle est volontairement explicite : on doit la taper.
#
# Règle de prudence : ce hook ne bloque JAMAIS sur une incertitude. Pas de fichier de plan trouvé,
# dossier illisible, fichier vide → on laisse passer en le disant. Empêcher quelqu'un d'avancer
# parce qu'on n'a pas su lire son plan serait un remède pire que le mal.
set -uo pipefail

cat >/dev/null 2>&1 || true   # on vide stdin : le JSON de l'appel ne nous apprend rien de plus

if [ "${PLAN_SANS_SCHEMA:-}" = "1" ]; then
  echo "⚠️  Contrôle du plan CONTOURNÉ (PLAN_SANS_SCHEMA=1) — assure-toi que ce plan n'en avait" >&2
  echo "    vraiment pas besoin : un chantier qui touche une architecture en a toujours besoin." >&2
  exit 0
fi

plans_dir="${CLAUDE_PLANS_DIR:-$HOME/.claude/plans}"
plan="${CLAUDE_PLAN_FILE:-}"

if [ -z "$plan" ]; then
  # Le plus récemment modifié. `find -newermt` évite un tri fragile sur les noms de fichiers.
  plan="$(find "$plans_dir" -maxdepth 1 -name '*.md' -type f -newermt '-12 hours' -printf '%T@ %p\n' 2>/dev/null \
          | sort -rn | head -1 | cut -d' ' -f2-)"
fi

# AUCUNE CERTITUDE, AUCUN BLOCAGE. On le dit, et on laisse passer.
if [ -z "$plan" ] || [ ! -r "$plan" ] || [ ! -s "$plan" ]; then
  echo "ℹ️  Contrôle du plan : aucun fichier de plan récent lisible dans $plans_dir — non vérifié." >&2
  exit 0
fi

# ON LIT LE FICHIER DIRECTEMENT, JAMAIS PAR UN TUYAU. Mesuré en écrivant ce hook : `printf "%s" "$t"
# | grep -q …` rend 141 (SIGPIPE) dès que grep sort au premier match, et `pipefail` transforme ce 141
# en échec — le contrôle déclarait alors manquante une section qui était là. Pire : le verdict
# dépendait de la taille du tampon du tuyau, donc il était juste ou faux selon la longueur du plan.
# Un garde-fou dont la réponse dépend d'une course n'est pas un garde-fou. `grep -i` sur le fichier
# supprime le tuyau, la mise en minuscules et le risque d'abîmer les accents, d'un seul geste.
manque=""
mentionne() { grep -qiE "$1" "$plan" 2>/dev/null; }

# 1. LE SCHÉMA. Contrôle STRUCTUREL, donc objectif : un bloc de code contenant des caractères de
#    dessin (cadres, flèches), ou un diagramme mermaid. C'est le seul des trois qui ne se devine pas.
if ! grep -qE '```mermaid' "$plan" 2>/dev/null \
   && ! grep -qE '[─│┌┐└┘├┤┬┴┼►◄▼▲→←↑↓╔╗╚╝║═]' "$plan" 2>/dev/null \
   && ! grep -qE '^[[:space:]]*[|+][-+= ]{3,}' "$plan" 2>/dev/null; then
  manque="${manque}
  • UN SCHÉMA. Au moins un bloc de dessin : les composants dans des cadres, ce qui circule entre eux
    en flèches. Un diagramme mermaid convient aussi. Sans dessin, le lecteur doit reconstruire la
    forme dans sa tête — c'est le travail qu'un plan est censé lui épargner."
fi

# 2. LE VERSANT ARCHITECTURAL : comment c'est construit.
if ! mentionne 'architectur|composant|module|brique|couche|interface|flux entre|schéma'; then
  manque="${manque}
  • LE VERSANT ARCHITECTURAL. Dis comment c'est construit : les composants, ce qui circule entre eux,
    les décisions prises et leur POURQUOI. Un plan qui n'énumère que des fichiers à modifier est une
    liste de courses, pas un plan."
fi

# 3. LE VERSANT FONCTIONNEL : ce que la personne vivra.
if ! mentionne "fonctionnel|parcours|règle métier|cas d.usage|scénario|à l.écran|à l'écran|utilisateur"; then
  manque="${manque}
  • LE VERSANT FONCTIONNEL. Dis ce que la personne vivra : les parcours, les règles, ce qu'elle verra
    à l'écran, ce qui change pour elle. C'est la seule partie que ton lecteur lira peut-être en
    entier — et c'est elle qui permet de dire oui ou non."
fi

[ -z "$manque" ] && exit 0

cat >&2 <<MSG
⛔ Plan incomplet — il lui manque de quoi être relu par un humain.

   Fichier : $plan

   Ce qui manque :$manque

   Complète le fichier de plan, puis rappelle ExitPlanMode. Ce contrôle ne juge pas le CONTENU de
   ton plan : il vérifie seulement qu'il porte les trois choses sans lesquelles on ne peut pas le
   relire — un dessin, comment c'est construit, et ce que ça change pour la personne.

   (Chantier minuscule qui n'en justifie vraiment aucun : PLAN_SANS_SCHEMA=1.)
MSG
exit 2

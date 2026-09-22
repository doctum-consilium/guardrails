#!/usr/bin/env bash
# Purpose : vérifier que les hooks généraux sont IDENTIQUES à leurs trois emplacements.
#
#           Les deux hooks (« un plan est architectural et fonctionnel », « écris pour un humain »)
#           vivent ici, sont copiés dans convkit pour que tout dépôt en hérite, et posés sur le poste
#           pour s'appliquer tout de suite. Trois copies d'un même contenu divergent au premier
#           correctif appliqué à une seule — c'est exactement la faute que ces règles combattent.
#           Ce script est le filet : il compare, il ne répare pas.
#
# Usage   : bash automation/hooks/verifier-les-copies.sh
#           Depuis n'importe où : le script se repère tout seul.
# Arguments : aucun. Emplacements surchargeables par CONVKIT_DIR et POSTE_HOOKS_DIR.
# Exit codes :
#   0  -> les copies présentes sont identiques (une copie ABSENTE est signalée, pas fatale :
#         un poste neuf ou un collègue sans convkit ne doit pas faire rougir le contrôle)
#   1  -> au moins une copie DIFFÈRE de la source
set -uo pipefail

ici="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
convkit="${CONVKIT_DIR:-$ici/../../../convkit}/templates/hooks"
poste="${POSTE_HOOKS_DIR:-$HOME/.claude/hooks}"

echec=0
for source in "$ici"/plan-architectural-et-fonctionnel.sh "$ici"/phrases-comprehensibles.sh; do
  nom="$(basename "$source")"
  for copie in "$convkit/$nom" "$poste/$nom"; do
    if [ ! -f "$copie" ]; then
      echo "○ absente : $copie (non vérifiée)"
      continue
    fi
    if cmp -s "$source" "$copie"; then
      echo "✓ identique : $copie"
    else
      echo "✗ DIFFÈRE de la source : $copie"
      echo "   source : $source"
      echo "   pour la réaligner : cp \"$source\" \"$copie\""
      echec=1
    fi
  done
done

[ "$echec" -eq 0 ] && echo "→ les copies présentes sont alignées."
exit "$echec"

#!/bin/bash

# Script entrypoint pour processGPX

perl processGPX -v
echo "--------------------------------"

case "$1" in
    "random")
        echo "🎲 Génération d'un fichier GPX aléatoire..."
        perl makeRandomRoute
        if [ -f "randomRoute.gpx" ]; then
            mv randomRoute.gpx /tmp/
            echo "✅ Fichier randomRoute.gpx généré et déplacé vers /tmp/"
        else
            echo "❌ Erreur: Fichier randomRoute.gpx non généré"
            exit 1
        fi
        ;;
    "process")
        echo "🔄 Traitement des fichiers GPX..."
        gpx_files=$(find /tmp/ -name "*.gpx" ! -name "*_processed*" ! -name ".*" 2>/dev/null)
        if [ -z "$gpx_files" ]; then
            echo "❌ Aucun fichier GPX à traiter trouvé dans /tmp/"
            exit 1
        fi
        echo "📁 Fichiers trouvés:"
        echo "$gpx_files"
        
        # Gestion des options supplémentaires
        shift  # Retire "process" des arguments
        if [ $# -gt 0 ]; then
            echo "🔧 Options supplémentaires: $*"
            perl processGPX $* $gpx_files
        else
            perl processGPX -auto $gpx_files
        fi
        echo "✅ Traitement terminé"
        ;;
    *)
        echo "Usage: docker run [options] dasgreff/processgpx [random|process [processGPX_options]]"
        echo ""
        echo "Commandes disponibles:"
        echo "  random            - Génère un fichier GPX aléatoire"
        echo "  process [options] - Traite les fichiers GPX existants"
        echo ""
        echo "Options processGPX principales:"
        echo "  -smooth <m>     - Lissage position/altitude (ex: -smooth 10)"
        echo "  -smoothZ <m>    - Lissage altitude uniquement (ex: -smoothZ 20)"
        echo "  -spacing <m>    - Espacement entre points (ex: -spacing 5)"
        echo "  -autoSpacing    - Espacement automatique dans les virages"
        echo "  -prune          - Supprime les points inutiles"
        echo "  -loop           - Traite comme un circuit bouclé"
        echo ""
        echo "Exemples:"
        echo "  docker run -v <votre_dossier_GPX>:/tmp --rm dasgreff/processgpx random"
        echo "  docker run -v <votre_dossier_GPX>:/tmp --rm dasgreff/processgpx process"
        echo "  docker run -v <votre_dossier_GPX>:/tmp --rm dasgreff/processgpx process -smooth 10 -prune"
        exit 1
        ;;
esac
# ProcessGPX Container

## Description

Ce projet fournit un conteneur Docker pour traiter les fichiers GPX (GPS Exchange Format) en utilisant l'outil [processGPX](https://github.com/djconnel/processGPX). Le conteneur permet de générer des routes aléatoires et de traiter automatiquement des fichiers GPX existants avec des fonctionnalités avancées d'analyse et d'optimisation.

## Fonctionnalités

- 🎲 **Génération aléatoire** : Création de fichiers GPX avec des routes aléatoires
- 🔄 **Traitement automatique** : Analyse et optimisation de fichiers GPX existants
- 📊 **Analyse complète** : Calculs de distance, vitesse, élévation et statistiques
- 🐳 **Containerisé** : Déploiement facile avec Docker
- 📁 **Montage de volumes** : Accès direct aux fichiers sur le système hôte
- ⚡ **Mode batch** : Traitement de plusieurs fichiers simultanément

## Prérequis

- Docker installé sur votre système
- Dossier contenant vos fichiers GPX (pour le mode process)

## Utilisation

### Commandes disponibles

Le conteneur supporte deux modes d'opération :

#### 1. Génération de route aléatoire (`random`)
Génère un nouveau fichier GPX avec une route aléatoire.

```bash
docker run -v /chemin/vers/vos/gpx:/tmp --rm processgpx:latest random
```

**Sortie :**
- Fichier `randomRoute.gpx` créé dans le dossier monté
- Contient une route générée aléatoirement

#### 2. Traitement de fichiers existants (`process`)
Analyse et traite tous les fichiers GPX trouvés dans le dossier monté.

```bash
# Traitement automatique (défaut)
docker run -v /chemin/vers/vos/gpx:/tmp --rm processgpx:latest process

# Traitement avec options personnalisées
docker run -v /chemin/vers/vos/gpx:/tmp --rm processgpx:latest process -smooth 15 -smoothZ 25 -prune
```

**Options processGPX disponibles :**
- `-auto` : Mode automatique avec paramètres optimaux (défaut si aucune option)
- `-smooth <mètres>` : Lissage de la position et altitude (ex: `-smooth 10`)
- `-smoothZ <mètres>` : Lissage d'altitude uniquement (ex: `-smoothZ 20`)
- `-spacing <mètres>` : Espacement entre points (ex: `-spacing 5`)
- `-autoSpacing` : Espacement automatique optimisé dans les virages
- `-prune` : Supprime les points colinéaires inutiles
- `-loop` : Traite la route comme un circuit bouclé
- Et bien d'autres options avancées...

**Fonctionnalités du traitement :**
- Calcul des distances et vitesses
- Analyse des profils d'élévation
- Statistiques détaillées du trajet
- Correction des données GPS
- Génération de rapports

### Exemples pratiques

#### Génération d'une route aléatoire
```bash
# Générer une route aléatoire dans le dossier local
docker run -v $(pwd)/gpx-files:/tmp --rm processgpx:latest random
```

#### Traitement de fichiers GPX existants
```bash
# Traiter tous les fichiers GPX du dossier (mode auto)
docker run -v /home/user/Documents/GPX:/tmp --rm processgpx:latest process

# Traitement avec options personnalisées
docker run -v /home/user/Documents/GPX:/tmp --rm processgpx:latest process -smooth 10 -prune
```

## Fonctionnement détaillé

### Mode `random`
1. **Génération** : Exécute le script `makeRandomRoute` de processGPX
2. **Vérification** : Contrôle que le fichier `randomRoute.gpx` est bien créé
3. **Déplacement** : Place le fichier dans `/tmp/` (dossier monté)
4. **Confirmation** : Affiche un message de succès ou d'erreur

### Mode `process`
1. **Recherche** : Scanne `/tmp/` pour trouver les fichiers `.gpx`
2. **Filtrage** : Exclut les fichiers déjà traités (`*_processed*`) et cachés (`.*`)
3. **Options** : Analyse les options supplémentaires passées en paramètre
4. **Traitement** : 
   - Sans options : Exécute `processGPX -auto` (mode automatique)
   - Avec options : Exécute `processGPX [options]` (mode personnalisé)
5. **Analyse** : Génère les statistiques et rapports selon les options

### Dépendances Perl incluses

Le conteneur inclut automatiquement les modules Perl nécessaires :
- `Getopt::Long` : Gestion des options en ligne de commande
- `XML::Descent` : Parsing des fichiers XML/GPX
- `POSIX` : Fonctions système POSIX
- `Date::Parse` : Analyse des dates et heures
- `Pod::Usage` : Documentation et aide
- `Geo::Gpx` : Manipulation des données GPX

## Format de sortie

### Fichiers générés

#### Mode `random`
- `randomRoute.gpx` : Fichier GPX avec route aléatoire

#### Mode `process`
- Fichiers d'analyse (formats variables selon processGPX)
- Rapports de statistiques
- Données de profil d'élévation
- Fichiers corrigés (selon configuration)

### Messages de sortie

```bash
# Mode random
🎲 Génération d'un fichier GPX aléatoire...
✅ Fichier randomRoute.gpx généré et déplacé vers /tmp/

# Mode process (sans options)
🔄 Traitement des fichiers GPX...
📁 Fichiers trouvés:
/tmp/track1.gpx
/tmp/track2.gpx
✅ Traitement terminé

# Mode process (avec options)
🔄 Traitement des fichiers GPX...
📁 Fichiers trouvés:
/tmp/track1.gpx
/tmp/track2.gpx
🔧 Options supplémentaires: -smooth 15 -smoothZ 25 -prune
✅ Traitement terminé
```

## Dépannage

### Problèmes courants

#### "Aucun fichier GPX à traiter trouvé"
- **Cause** : Pas de fichiers `.gpx` dans le dossier monté
- **Solution** : Vérifiez que vos fichiers GPX sont dans le bon dossier

#### "Fichier randomRoute.gpx non généré"
- **Cause** : Erreur dans la génération aléatoire
- **Solution** : Vérifiez les logs d'erreur du conteneur

#### Erreurs de permissions
- **Cause** : Permissions insuffisantes sur le dossier monté
- **Solution** : Ajustez les permissions du dossier hôte

### Vérification des fichiers

```bash
# Lister les fichiers GPX dans le dossier
ls -la /chemin/vers/vos/gpx/*.gpx

# Vérifier les permissions
ls -ld /chemin/vers/vos/gpx/
```

## Exemples d'utilisation avancée

### Options processGPX détaillées

Pour connaître toutes les options disponibles de processGPX :

```bash
# Afficher l'aide
docker run --rm processgpx:latest
```

**Options couramment utilisées :**
- `-auto` : Mode automatique avec paramètres optimaux
- `-smooth <m>` : Lissage position/altitude (ex: 10-20 mètres)
- `-smoothZ <m>` : Lissage altitude seule (généralement > smooth)
- `-spacing <m>` : Densité des points (3-10 mètres selon la complexité)
- `-autoSpacing` : Espacement adaptatif dans les virages
- `-prune` : Optimise le nombre de points
- `-loop` : Pour les circuits fermés
- `-quiet` : Mode silencieux

### Exemples d'utilisation avancée

#### Script de traitement automatisé
```bash
#!/bin/bash
# Script pour traiter automatiquement les nouveaux fichiers GPX

GPX_DIR="/home/user/GPS/tracks"
BACKUP_DIR="/home/user/GPS/processed"

# Créer une sauvegarde
cp -r "$GPX_DIR" "$BACKUP_DIR/$(date +%Y%m%d_%H%M%S)"

# Traitement détaillé avec options personnalisées
docker run -v "$GPX_DIR":/tmp --rm processgpx:latest process -smooth 12 -smoothZ 18 -autoSpacing -prune

echo "Traitement terminé. Vérifiez les résultats dans $GPX_DIR"
```

#### Traitement silencieux
```bash
# Traitement silencieux optimisé
docker run -v /path/to/gpx:/tmp --rm processgpx:latest process -auto -quiet -prune
```

## À propos de processGPX

Ce conteneur utilise l'outil [processGPX](https://github.com/djconnel/processGPX) développé par djconnel. ProcessGPX est un outil Perl avancé pour l'analyse et le traitement de fichiers GPX avec des fonctionnalités incluant :

- Calculs de vitesse et distance précis
- Analyse de profils d'élévation
- Correction des données GPS
- Génération de statistiques détaillées
- Support de multiples formats de sortie

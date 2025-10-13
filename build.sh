#!/bin/bash

# Télécharger Flutter SDK stable
git clone https://github.com/flutter/flutter.git -b stable

# Ajouter Flutter au PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Vérifier Flutter
flutter --version

# Récupérer les dépendances
flutter pub get

# Compiler l'app Web
flutter build web --release

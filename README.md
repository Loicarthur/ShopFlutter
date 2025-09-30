# FlutCom - Application E-commerce

Ce projet est une application e-commerce développée avec Flutter, suivant l'architecture MVVM (Model-View-ViewModel).

## ✨ Fonctionnalités

- **Catalogue de produits** : Affiche les produits depuis une API.
- **Détail produit** : Vue détaillée pour chaque produit.
- **Panier** : Ajout et gestion des articles dans le panier.
- **Commandes** : Historique des commandes passées.
- **Authentification** : Inscription et connexion des utilisateurs.

## 🏗️ Architecture

Le projet est structuré en suivant le pattern MVVM pour une meilleure séparation des responsabilités :

- `lib/models`: Contient les modèles de données (ex: `Product`, `Order`).
- `lib/services`: Gère les appels API et l'authentification.
- `lib/viewmodels`: Contient la logique métier et la gestion de l'état avec `Provider`.
- `lib/views`: Contient les écrans de l'application.
- `lib/widgets`: Contient les composants réutilisables.

## 🚀 Démarrage

1. **Installer les dépendances** :
   ```bash
   flutter pub get
   ```

2. **Lancer l'application** :
   ```bash
   flutter run
   ```

## 🧪 Tests

Pour lancer tous les tests du projet, utilisez la commande suivante :

```bash
flutter test test/test_all.dart
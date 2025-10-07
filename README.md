# FlutCom - Application E-commerce

Ce projet est une application e-commerce développée avec Flutter, suivant l'architecture MVVM (Model-View-ViewModel).

## ✨ Fonctionnalités

- **Catalogue de produits** : Affiche les produits depuis une API.
- **Détail produit** : Vue détaillée pour chaque produit.
- **Panier** : Ajout et gestion des articles dans le panier.
- **Commandes** : Historique des commandes passées.
- **Authentification** : Inscription et connexion des utilisateurs.

## 📦 Source des Données

**Important** : Actuellement, l'application utilise une API de test ([Fake Store API](https://fakestoreapi.com/)). Les produits, les catégories et les utilisateurs sont donc des **données mockées** et ne sont pas réels.

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
```

## ⚙️ CI/CD avec GitHub Actions

Ce projet utilise [GitHub Actions](https://github.com/features/actions) pour l'intégration continue. Le workflow est déclenché à chaque `push` sur la branche `main` et effectue les tâches suivantes :
- **Vérification du formatage** : S'assure que tout le code Dart est correctement formaté.
- **Analyse statique** : Détecte les erreurs et les problèmes potentiels dans le code avec `flutter analyze`.
- **Exécution des tests** : Lance la suite de tests complète pour valider le bon fonctionnement de l'application.

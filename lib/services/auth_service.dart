import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Permet l'injection de dépendance pour les tests
  AuthService({FirebaseAuth? firebaseAuth}) : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  // 🔹 Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // 🔹 État de l'utilisateur (stream)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 🔹 Inscription
  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // 🔹 Alias utilisés par les tests
  Future<UserCredential> loginWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // 🔹 Connexion
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // 🔹 Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 🔹 Alias test
  Future<void> logout() => signOut();

  // 🔹 Gestion des erreurs
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-disabled':
        return 'Utilisateur désactivé.';
      case 'user-not-found':
        return 'Utilisateur non trouvé.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cette adresse email est déjà utilisée.';
      case 'weak-password':
        return 'Mot de passe trop faible.';
      case 'operation-not-allowed':
        return 'Connexion par email/mot de passe désactivée.';
      default:
        return 'Erreur inconnue : ${e.message}';
    }
  }
}

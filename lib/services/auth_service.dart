import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Singleton pour utiliser la même instance partout
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;

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

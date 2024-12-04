import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthService {
  Future<void> signOut();

  Future<bool> login({required String email, required String password});

  Future<bool> register({required String email, required String password});
}

class AuthException {
  final String message;

  AuthException(
    this.message,
  );
}

class AuthService implements IAuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<bool> login({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message!);
    }
  }

  @override
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message!);
    }
  }
}

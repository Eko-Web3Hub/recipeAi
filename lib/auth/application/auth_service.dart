import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/utils/app_text.dart';

abstract class IAuthService {
  Future<void> signOut();

  Future<bool> login({required String email, required String password});

  Future<bool> register({required String email, required String password});

  Future<bool> sendPasswordResetEmail({required String email});
}

class AuthException extends Equatable {
  final String message;

  const AuthException(
    this.message,
  );

  @override
  List<Object?> get props => [message];
}

class AuthService implements IAuthService {
  final IFirebaseAuth _firebaseAuth;

  AuthService(
    this._firebaseAuth,
  );

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<bool> login({
    required String email,
    required String password,
  }) async {
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

  @override
  Future<bool> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email' || e.code == 'user-not-found') {
        throw const AuthException(appTexts.userNotFound);
      } else {
        throw const AuthException(appTexts.somethingWentWrong);
      }
    }
    return true;
  }
}

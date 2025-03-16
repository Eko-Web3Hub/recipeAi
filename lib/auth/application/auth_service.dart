import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

abstract class IAuthService {
  Future<void> signOut();

  Future<bool> login({required String email, required String password});

  Future<bool> googleSignIn();
  Future<bool> appleSignIn();

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
        throw AuthException(AuthError.userNotFound.name);
      } else {
        throw AuthException(
          AuthError.somethingWentWrong.name,
        );
      }
    }
    return true;
  }

  @override
  Future<bool> googleSignIn() async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      //user cancels google sign in pop up screen
      if (gUser == null) return false;

      //obtain auth details from request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      //create new credential for User
      final credentials = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken, idToken: gAuth.idToken);

      //sign in
      await _firebaseAuth.signInWithCredentials(credentials);
      return true;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message!);
    }
  }

  @override
  Future<bool> appleSignIn() async {
    try {
      final appleCredentials = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName
          ]);

      final oAuthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredentials.identityToken,
          accessToken: appleCredentials.authorizationCode);
      await _firebaseAuth.signInWithCredentials(oAuthCredential);
      return true;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message!);
    }
  }
}

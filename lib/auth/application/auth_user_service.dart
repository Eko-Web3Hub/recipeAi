import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthUserService {
  User? get currentUser;
  Stream<User?> get authStateChanges;
}

class AuthUserService implements IAuthUserService {
  final FirebaseAuth _firebaseAuth;

  AuthUserService(
    this._firebaseAuth,
  );

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;
}

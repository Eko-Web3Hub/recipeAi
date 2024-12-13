import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthUserService {
  AuthUser? get currentUser;
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
  AuthUser? get currentUser => _firebaseAuth.currentUser == null
      ? null
      : AuthUser(
          uid: _firebaseAuth.currentUser!.uid,
          email: _firebaseAuth.currentUser!.email!,
        );
}

class AuthUser extends Equatable {
  final String uid;
  final String email;

  const AuthUser({
    required this.uid,
    required this.email,
  });

  @override
  List<Object?> get props => [uid, email];
}

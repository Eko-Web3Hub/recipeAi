import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_ai/ddd/entity.dart';

abstract class IAuthUserService {
  AuthUser? get currentUser;
  Stream<AuthUser?> get authStateChanges;
}

class AuthUserService implements IAuthUserService {
  final FirebaseAuth _firebaseAuth;

  AuthUserService(
    this._firebaseAuth,
  );

  @override
  Stream<AuthUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map((currentUser) {
        if (currentUser == null) {
          return null;
        }
        return AuthUser(
          uid: EntityId(currentUser.uid),
          email: currentUser.email,
        );
      });

  @override
  AuthUser? get currentUser => _firebaseAuth.currentUser == null
      ? null
      : AuthUser(
          uid: EntityId(_firebaseAuth.currentUser!.uid),
          email: _firebaseAuth.currentUser!.email,
        );
}

class AuthUser extends Equatable {
  final EntityId uid;
  final String? email;

  const AuthUser({
    required this.uid,
    required this.email,
  });

  @override
  List<Object?> get props => [uid, email];
}

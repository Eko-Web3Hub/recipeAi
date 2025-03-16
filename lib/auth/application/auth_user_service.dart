import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/ddd/entity.dart';

abstract class IAuthUserService {
  AuthUser? get currentUser;
  Stream<AuthUser?> get authStateChanges;
}

class RequiresRecentLoginException implements Exception {}

class DeleteAccountExeption implements Exception {
  final String message;

  DeleteAccountExeption(this.message);
}

abstract class IFirebaseAuth {
  Future<void> sendPasswordResetEmail(String email);
  Future<void> deleteAccount();

  Future<void> signInWithCredentials(OAuthCredential credentials);
  Future<void> signOut();
  Future<void> signInWithEmailAndPassword(
      {required String email, required String password});
  Future<void> createUserWithEmailAndPassword(
      {required String email, required String password});
  Stream<User?> get authStateChanges;
  User? get currentUser;
}

class FirebaseAuthProd implements IFirebaseAuth {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthProd(
    this._firebaseAuth,
  );

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

  @override
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  @override
  Future<void> deleteAccount() {
    return _firebaseAuth.currentUser!.delete();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _firebaseAuth.sendPasswordResetEmail(
        email: email,
      );

  @override
  Future<void> signInWithCredentials(OAuthCredential credentials) =>
      _firebaseAuth.signInWithCredential(credentials);
}

class AuthUserService implements IAuthUserService {
  final IFirebaseAuth _firebaseAuth;
  final IAnalyticsRepository _analyticsRepository;

  AuthUserService(
    this._firebaseAuth,
    this._analyticsRepository,
  );

  @override
  Stream<AuthUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges.map((currentUser) {
        _analyticsRepository.setUserId(currentUser?.uid ?? '');
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

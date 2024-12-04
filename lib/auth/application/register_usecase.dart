import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:recipe_ai/auth/domain/repositories/user_personnal_info_repository.dart';

class RegisterUsecase {
  final FirebaseAuth _firebaseAuth;
  final IUserPersonnalInfoRepository _userPersonnalInfoRepository;

  RegisterUsecase(
    this._firebaseAuth,
    this._userPersonnalInfoRepository,
  );
}

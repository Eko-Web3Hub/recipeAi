import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class RegisterControllerState extends Equatable {}

class RegisterControllerSuccess extends RegisterControllerState {
  @override
  List<Object?> get props => [];
}

class RegisterControllerFailed extends RegisterControllerState {
  @override
  List<Object?> get props => [];
}

class RegisterController extends Cubit<RegisterControllerState?> {
  RegisterController() : super(null);

  void register() {
    emit(RegisterControllerSuccess());
  }
}

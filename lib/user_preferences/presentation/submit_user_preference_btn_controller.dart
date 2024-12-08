import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SubmitUserPreferenceBtnState {}

class SubmitUserPreferenceBtnInitial extends SubmitUserPreferenceBtnState {}

class SubmitUserPreferenceBtnLoading extends SubmitUserPreferenceBtnState {}

class SubmitUserPreferenceBtnSuccess extends SubmitUserPreferenceBtnState {}

class SubmitUserPreferenceBtnError extends SubmitUserPreferenceBtnState {}

class SubmitUserPreferenceBtnController
    extends Cubit<SubmitUserPreferenceBtnState> {
  SubmitUserPreferenceBtnController() : super(SubmitUserPreferenceBtnInitial());

  void submit() {
    emit(SubmitUserPreferenceBtnLoading());
    try {
      // Call the API to submit the user preferences
      emit(SubmitUserPreferenceBtnSuccess());
    } catch (e) {
      emit(SubmitUserPreferenceBtnError());
    }
  }
}

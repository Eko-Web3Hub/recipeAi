// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter_bloc/flutter_bloc.dart';

extension SafeEmitter<T> on Cubit<T> {
  void safeEmit(T value) {
    if (!isClosed) {
      // ignore: invalid_use_of_visible_for_testing_member
      emit(value);
    }
  }
}

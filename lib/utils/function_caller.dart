import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';

const _functionsRegion = 'europe-west1';

class FunctionsCaller {
  const FunctionsCaller(this._functions);

  FunctionsCaller.inject()
      : this(
          FirebaseFunctions.instanceFor(region: _functionsRegion),
        );

  final FirebaseFunctions _functions;

  Future<Map<String, dynamic>> callFunction(
    String name,
    Map<String, dynamic> input,
  ) async {
    try {
      final response = await _functions
          .httpsCallable(name, options: HttpsCallableOptions())
          .call<dynamic>(input);

      log('response: ${response.data}');
      return response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : {};
    } on FirebaseFunctionsException catch (e) {
      log('Error calling function: ${e.code} - ${e.message}');

      return {};
    }
  }
}

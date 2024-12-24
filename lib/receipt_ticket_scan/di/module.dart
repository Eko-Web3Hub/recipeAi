import 'package:dio/dio.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';
import 'package:recipe_ai/receipt_ticket_scan/application/repositories/receipt_ticket_scan_repository.dart';
import 'package:recipe_ai/receipt_ticket_scan/infrastructure/receipt_ticket_scan_repository.dart';

class ReceiptTicketScanModule implements IDiModule {
  const ReceiptTicketScanModule();

  @override
  void register(DiContainer di) {
    di.registerLazySingleton<IReceiptTicketScanRepository>(
      () => FastApiReceiptTicketScanRepository(
        di<Dio>(),
      ),
    );
  }
}

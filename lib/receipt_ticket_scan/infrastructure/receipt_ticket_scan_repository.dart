import 'package:dio/dio.dart';
import 'package:recipe_ai/receipt_ticket_scan/application/models/receipt_ticket.dart';
import 'package:recipe_ai/receipt_ticket_scan/application/repositories/receipt_ticket_scan_repository.dart';

class FastApiReceiptTicketScanRepository
    implements IReceiptTicketScanRepository {
  final Dio _dio;

  FastApiReceiptTicketScanRepository(
    this._dio,
  );

  @override
  Future<ReceiptTicket> retrieve() {
    throw UnimplementedError();
  }
}

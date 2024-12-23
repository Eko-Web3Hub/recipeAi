import 'package:recipe_ai/receipt_ticket_scan/application/models/receipt_ticket.dart';

abstract class IReceiptTicketScanRepository {
  Future<ReceiptTicket> retrieve();
}

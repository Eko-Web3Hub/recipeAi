import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_ai/kitchen/presentation/receipt_ticket_scan_controller.dart';

void main() {
  ReceiptTicketScanController buildSut() {
    return ReceiptTicketScanController();
  }

  blocTest<ReceiptTicketScanController, ReceiptTicketScanState>(
    'should initialy be loading',
    build: () => buildSut(),
    verify: (bloc) {
      expect(bloc.state, ReceiptTicketScanLoading());
    },
  );
}

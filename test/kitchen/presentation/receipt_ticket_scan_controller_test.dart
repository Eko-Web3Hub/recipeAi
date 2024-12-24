import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/kitchen/presentation/receipt_ticket_scan_controller.dart';
import 'package:recipe_ai/receipt_ticket_scan/application/models/receipt_ticket.dart';
import 'package:recipe_ai/receipt_ticket_scan/application/repositories/receipt_ticket_scan_repository.dart';

class ReceiptTicketScanRepository extends Mock
    implements IReceiptTicketScanRepository {}

void main() {
  late IReceiptTicketScanRepository receiptTicketScanRepository;
  final file = File('test.jpg');
  const receipt = ReceiptTicket(
    superMarketName: 'superMarketName',
    adresse: 'adresse',
    date: 'date',
    products: [],
    totalPricePayed: "2€",
  );

  setUp(() {
    receiptTicketScanRepository = ReceiptTicketScanRepository();
  });

  ReceiptTicketScanController buildSut() {
    return ReceiptTicketScanController(
      receiptTicketScanRepository,
    );
  }

  blocTest<ReceiptTicketScanController, ReceiptTicketScanState>(
    'should initialy be in initial state',
    build: () => buildSut(),
    verify: (bloc) {
      expect(bloc.state, ReceiptTicketScanInitial());
    },
  );

  blocTest<ReceiptTicketScanController, ReceiptTicketScanState>(
    'should scan receipt ticket',
    build: () => buildSut(),
    setUp: () {
      when(() => receiptTicketScanRepository.retrieve(file: file))
          .thenAnswer((_) => Future.value(receipt));
    },
    act: (bloc) => bloc.scanReceiptTicket(file),
    expect: () => [
      ReceiptTicketScanLoading(),
      ReceiptTicketScanLoaded(receipt),
    ],
  );

  blocTest<ReceiptTicketScanController, ReceiptTicketScanState>(
    'should emit error when scan receipt ticket fails',
    build: () => buildSut(),
    setUp: () {
      when(() => receiptTicketScanRepository.retrieve(file: file))
          .thenThrow(Exception());
    },
    act: (bloc) => bloc.scanReceiptTicket(file),
    expect: () => [
      ReceiptTicketScanLoading(),
      isA<ReceiptTicketScanError>(),
    ],
  );
}

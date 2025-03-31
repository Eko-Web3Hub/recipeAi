import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/kitchen/presentation/receipt_ticket_scan_controller.dart';
import 'package:recipe_ai/receipt_ticket_scan/application/models/receipt_ticket.dart';
import 'package:recipe_ai/receipt_ticket_scan/application/repositories/receipt_ticket_scan_repository.dart';

class ReceiptTicketScanRepository extends Mock
    implements IReceiptTicketScanRepository {}

class AnalyticsRepository extends Mock implements IAnalyticsRepository {}

class AuthUserService extends Mock implements IAuthUserService {}

void main() {
  late IReceiptTicketScanRepository receiptTicketScanRepository;
  late IAnalyticsRepository analyticsRepository;
  late IAuthUserService authUserService;

  final file = File('test.jpg');
  final authUser = AuthUser(
    uid: EntityId('uid'),
    email: 'test@gmail.com',
  );
  const receipt = ReceiptTicket(
    superMarketName: 'superMarketName',
    adresse: 'adresse',
    date: 'date',
    products: [],
    totalPricePayed: "2€",
  );

  setUpAll(() {
    registerFallbackValue(TicketScanSuccessEvent());
  });

  setUp(() {
    receiptTicketScanRepository = ReceiptTicketScanRepository();
    analyticsRepository = AnalyticsRepository();
    authUserService = AuthUserService();

    when(() => authUserService.currentUser).thenAnswer((_) => authUser);
    when(() => analyticsRepository.logEvent(any())).thenAnswer(
      (_) => Future.value(),
    );
  });

  ReceiptTicketScanController buildSut() {
    return ReceiptTicketScanController(
      receiptTicketScanRepository,
      analyticsRepository,
      authUserService,
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

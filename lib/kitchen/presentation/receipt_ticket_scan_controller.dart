import 'dart:developer';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/receipt_ticket_scan/application/models/receipt_ticket.dart';

import '../../receipt_ticket_scan/application/repositories/receipt_ticket_scan_repository.dart';

abstract class ReceiptTicketScanState extends Equatable {}

class ReceiptTicketScanInitial extends ReceiptTicketScanState {
  @override
  List<Object?> get props => [];
}

class ReceiptTicketScanLoading extends ReceiptTicketScanState {
  @override
  List<Object?> get props => [];
}

class ReceiptTicketScanLoaded extends ReceiptTicketScanState {
  final ReceiptTicket receiptTicket;

  ReceiptTicketScanLoaded(
    this.receiptTicket,
  );

  @override
  List<Object?> get props => [receiptTicket];
}

class ReceiptTicketScanError extends ReceiptTicketScanState {
  ReceiptTicketScanError();

  @override
  List<Object?> get props => [];
}

class ReceiptTicketScanController extends Cubit<ReceiptTicketScanState> {
  ReceiptTicketScanController(
    this._receiptTicketScanRepository,
    this._analyticsRepository,
    this._authUserService,
  ) : super(
          ReceiptTicketScanInitial(),
        );

  final IReceiptTicketScanRepository _receiptTicketScanRepository;
  final IAnalyticsRepository _analyticsRepository;
  final IAuthUserService _authUserService;

  Future<void> scanReceiptTicket(File file) async {
    try {
      emit(
        ReceiptTicketScanLoading(),
      );
      final result = await _receiptTicketScanRepository.retrieve(
        file: file,
      );
      _analyticsRepository.logEvent(TicketScanSuccessEvent());
      emit(
        ReceiptTicketScanLoaded(result),
      );
    } catch (e) {
      log(e.toString());
      _analyticsRepository.logEvent(
        TicketScanErrorEvent(
          parameters: {
            'uid': _authUserService.currentUser!.uid,
            'error': e.toString(),
          },
        ),
      );
      emit(
        ReceiptTicketScanError(),
      );
    }
  }
}

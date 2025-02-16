import 'dart:developer';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/receipt_ticket_scan/application/models/receipt_ticket.dart';
import 'package:recipe_ai/utils/app_text.dart';

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
  final String message;

  ReceiptTicketScanError(
    this.message,
  );

  @override
  List<Object?> get props => [
        message,
      ];
}

class ReceiptTicketScanController extends Cubit<ReceiptTicketScanState> {
  ReceiptTicketScanController(
    this._receiptTicketScanRepository,
  ) : super(
          ReceiptTicketScanInitial(),
        );

  final IReceiptTicketScanRepository _receiptTicketScanRepository;

  Future<void> scanReceiptTicket(File file) async {
    try {
      emit(
        ReceiptTicketScanLoading(),
      );
      final result = await _receiptTicketScanRepository.retrieve(
        file: file,
      );
      emit(
        ReceiptTicketScanLoaded(result),
      );
    } catch (e) {
      log(e.toString());
      emit(
        ReceiptTicketScanError(
          appTexts.receiptTicketScanError,
        ),
      );
    }
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ReceiptTicketScanState extends Equatable {}

class ReceiptTicketScanLoading extends ReceiptTicketScanState {
  @override
  List<Object?> get props => [];
}

class ReceiptTicketScanController extends Cubit<ReceiptTicketScanState> {
  ReceiptTicketScanController()
      : super(
          ReceiptTicketScanLoading(),
        );
}

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:recipe_ai/receipt_ticket_scan/application/models/receipt_ticket.dart';
import 'package:recipe_ai/receipt_ticket_scan/application/repositories/receipt_ticket_scan_repository.dart';
import 'package:recipe_ai/receipt_ticket_scan/infrastructure/serialization/receipt_ticket_scan_serialization.dart';
import 'package:recipe_ai/utils/constant.dart';

class FastApiReceiptTicketScanRepository
    implements IReceiptTicketScanRepository {
  final Dio _dio;

  static const String path =
      "$baseApiUrl/extract-ingrediants-from-receipt-picture";

  FastApiReceiptTicketScanRepository(
    this._dio,
  );

  @override
  Future<ReceiptTicket> retrieve({
    required File file,
  }) async {
    try {
      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: file.path.split("/").last,
        ),
      });
      final response = await _dio.post(path, data: formData);
      final receiptTicket = response.data['receiptTicket'];

      return ReceiptTicketScanSerialization.fromJson(receiptTicket);
    } catch (e) {
      throw Exception("Failed to retrieve receipt ticket");
    }
  }
}

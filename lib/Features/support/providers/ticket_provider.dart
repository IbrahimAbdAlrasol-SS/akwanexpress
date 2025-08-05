import 'dart:async';
import 'package:Tosell/Features/support/models/ticket.dart';
import 'package:Tosell/Features/support/services/ticket_service.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ticket_provider.g.dart';

@riverpod
class TicketNotifier extends _$TicketNotifier {
  final TicketService _service = TicketService();

  Future<ApiResponse<Ticket>> getAll(
      {int page = 1, Map<String, dynamic>? queryParams}) async {
    return (await _service.getAll(page: page, queryParams: queryParams));
  }

  Future<ApiResponse<Ticket>?> createOrderTicket(
      {required String orderId,
      String? subject,
      required String description}) async {
    return (await _service.createOrderTicket(
      orderId: orderId,
      subject: subject,
      description: description,
    ));
  }

  Future<ApiResponse<Ticket>?> createShipmentTicket(
      {required String shipmentId,
      String? subject,
      required String description}) async {
    return (await _service.createOrderTicket(
      orderId: shipmentId,
      subject: subject,
      description: description,
    ));
  }

  Future<ApiResponse<Ticket>?> createGeneralTicket({
    required String subject,
    required String description,
  }) async {
    return (await _service.createGeneralTicket(
      subject: subject,
      description: description,
    ));
  }

  @override
  FutureOr<ApiResponse<Ticket>?> build() async {
    return await getAll();
  }
}

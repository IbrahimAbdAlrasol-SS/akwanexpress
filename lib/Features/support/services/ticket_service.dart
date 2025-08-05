import 'package:Tosell/Features/support/models/ticket.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:Tosell/core/Client/BaseClient.dart';

class TicketService {
  final BaseClient<Ticket> baseClient;

  TicketService()
      : baseClient =
            BaseClient<Ticket>(fromJson: (json) => Ticket.fromJson(json));

  Future<ApiResponse<Ticket>> getAll(
      {int page = 1, Map<String, dynamic>? queryParams}) async {
    try {
      var result = await baseClient.getAll(
          endpoint: '/ticket', page: page, queryParams: queryParams);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Ticket>?> createOrderTicket({
    required String orderId,
    String? subject,
    required String description,
  }) async {
    try {
      var result = await baseClient.create(
        endpoint: '/ticket/order/by-user',
        data: {
          'subject': subject,
          'description': description,
          'referenceId': orderId
        },
      );

      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Ticket>?> createShipmentTicket({
    required String shipmentId,
    String? subject,
    required String description,
  }) async {
    try {
      var result = await baseClient.create(
        endpoint: '/ticket/shipment/by-user',
        data: {
          'subject': subject,
          'description': description,
          'referenceId': shipmentId
        },
      );

      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Ticket>?> createGeneralTicket({
    required String subject,
    required String description,
  }) async {
    try {
      var result = await baseClient.create(
        endpoint: '/ticket/by-user',
        data: {
          'subject': subject,
          'description': description,
        },
      );

      return result;
    } catch (e) {
      rethrow;
    }
  }
}

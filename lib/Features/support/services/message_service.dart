import 'package:Tosell/Features/support/models/chat_message.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:Tosell/core/Client/BaseClient.dart';

class MessageService {
  final BaseClient<ChatMessage> baseClient;

  MessageService()
      : baseClient = BaseClient<ChatMessage>(
            fromJson: (json) => ChatMessage.fromJson(json));

  Future<ApiResponse<ChatMessage>> getAll(
      {required String ticketId,
      int page = 1,
      Map<String, dynamic>? queryParams}) async {
    try {
      var result = await baseClient.getAll(
        endpoint: '/ticket/$ticketId/messages',
        page: page,
        queryParams: queryParams,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }
}

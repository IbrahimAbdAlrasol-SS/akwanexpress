import 'package:Tosell/Features/notification/models/notifications.dart';
import 'package:Tosell/core/Client/BaseClient.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';

class NotificationsService {
  final BaseClient<Notifications> baseClient;

  NotificationsService()
      : baseClient = BaseClient<Notifications>(
            fromJson: (json) => Notifications.fromJson(json));

  Future<ApiResponse<Notifications>> getAll(
      {int page = 1, Map<String, dynamic>? queryParams}) async {
    try {
      var result = await baseClient.getAll(
          endpoint: '/notifications/my-notifications',
          page: page,
          queryParams: queryParams);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}

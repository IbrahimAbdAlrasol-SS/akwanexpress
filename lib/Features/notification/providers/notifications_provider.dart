import 'dart:async';
import 'package:Tosell/Features/notification/models/notifications.dart';
import 'package:Tosell/Features/notification/services/notifications_service.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_provider.g.dart';

@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  final NotificationsService _service = NotificationsService();

  Future<ApiResponse<Notifications>> getAll(
      {int page = 1, Map<String, dynamic>? queryParams}) async {
    return (await _service.getAll(page: page, queryParams: queryParams));
  }

  @override
  FutureOr<ApiResponse<Notifications>> build() async {
    return await getAll();
  }
}

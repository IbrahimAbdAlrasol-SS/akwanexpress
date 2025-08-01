import 'package:Tosell/Features/home/models/RejectReasons.dart';
import 'package:Tosell/core/Client/BaseClient.dart';

class RejectReasonService {
  final BaseClient<RejectReason> baseClient;

  RejectReasonService()
      : baseClient = BaseClient<RejectReason>(
            fromJson: (json) => RejectReason.fromJson(json));

  Future<List<RejectReason>> getAll() async {
    try {
      // var result = await baseClient.get(endpoint: 'dashboard/mobile');
      var result =
          await baseClient.getAll(endpoint: '/reject-reasons/no-pagination');
      // if (result.singleData == null) return Home();
      return result.data ?? [];
    } catch (e) {
      rethrow;
    }
  }
}

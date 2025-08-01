import 'dart:async';
import 'package:Tosell/Features/home/models/RejectReasons.dart';
import 'package:Tosell/Features/home/services/RejectReasonService.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reject_reson_provider.g.dart';

@riverpod
class RejectResonNotifier extends _$RejectResonNotifier {
  final RejectReasonService _service = RejectReasonService();

  Future<List<RejectReason>> getAll() async {
    return (await _service.getAll());
  }

  @override
  FutureOr<List<RejectReason>> build() async {
    return await getAll();
  }
}

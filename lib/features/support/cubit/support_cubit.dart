import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SupportState {}
class SupportInitial extends SupportState {}

class SupportCubit extends Cubit<SupportState> {
  SupportCubit() : super(SupportInitial());
}

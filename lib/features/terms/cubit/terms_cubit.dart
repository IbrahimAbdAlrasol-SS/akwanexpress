import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TermsState {}
class TermsInitial extends TermsState {}

class TermsCubit extends Cubit<TermsState> {
  TermsCubit() : super(TermsInitial());
}

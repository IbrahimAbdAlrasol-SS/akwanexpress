import 'package:flutter_bloc/flutter_bloc.dart';

abstract class WalletState {}
class WalletInitial extends WalletState {}

class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(WalletInitial());
}

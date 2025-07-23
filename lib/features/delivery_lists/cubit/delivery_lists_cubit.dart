import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeliveryListsState {}
class DeliveryListsInitial extends DeliveryListsState {}

class DeliveryListsCubit extends Cubit<DeliveryListsState> {
  DeliveryListsCubit() : super(DeliveryListsInitial());
}

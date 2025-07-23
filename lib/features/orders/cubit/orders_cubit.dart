import 'package:flutter_bloc/flutter_bloc.dart';
import 'orders_state.dart';

/// ÙƒÙŠÙˆØ¨Øª Ø§Ù„Ø·Ù„Ø¨Ø§Øª
/// Orders cubit
class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersInitial());
  
  Future<void> loadOrders() async {
    emit(OrdersLoading());
    try {
      // TODO: ØªØ­Ù…ÙŠÙ„ Ø§Ù„Ø·Ù„Ø¨Ø§Øª
      // TODO: Load orders
      emit(OrdersLoaded([]));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }
}

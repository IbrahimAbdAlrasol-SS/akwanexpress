/// Ø­Ø§Ù„Ø§Øª Ø§Ù„Ø·Ù„Ø¨Ø§Øª
/// Orders states
abstract class OrdersState {}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<dynamic> orders;
  OrdersLoaded(this.orders);
}

class OrdersError extends OrdersState {
  final String message;
  OrdersError(this.message);
}

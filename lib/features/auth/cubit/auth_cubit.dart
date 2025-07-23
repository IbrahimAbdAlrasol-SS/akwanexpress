import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {

      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> register(String name, String email, String password, String phone) async {
    emit(AuthLoading());
    try {
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

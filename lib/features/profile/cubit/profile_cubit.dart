import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProfileState {}
class ProfileInitial extends ProfileState {}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fr_app/db/databse_helper.dart';
import 'package:fr_app/models/user_model.dart';
import 'package:meta/meta.dart';

part 'registered_user_state.dart';

class RegisteredUserCubit extends Cubit<RegisteredUserState> {
  final DatabaseHelper _databaseHelper;

  RegisteredUserCubit(this._databaseHelper) : super(RegisteredUserInitial());

  void getRegisteredUsers() async {
    emit(RegisteredUserLoading());

    try {
      final result = await _databaseHelper.queryAllUsers();
      emit(RegisteredUserLoaded(users: result));
    } catch (e) {
      emit(RegisteredUserError(e.toString()));
    }
  }
}

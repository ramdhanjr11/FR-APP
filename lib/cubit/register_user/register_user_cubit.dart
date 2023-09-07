import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fr_app/db/databse_helper.dart';
import 'package:fr_app/models/user_model.dart';
import 'package:fr_app/services/camera.service.dart';
import 'package:fr_app/services/face_detector_service.dart';
import 'package:fr_app/services/ml_service.dart';
import 'package:meta/meta.dart';

part 'register_user_state.dart';

class RegisterUserCubit extends Cubit<RegisterUserState> {
  final CameraService _cameraService;
  final FaceDetectorService _faceDetectorService;
  final MLService _mlService;
  final DatabaseHelper _databaseHelper;

  RegisterUserCubit(
    this._cameraService,
    this._faceDetectorService,
    this._mlService,
    this._databaseHelper,
  ) : super(RegisterUserInitial());

  void getRegisteredUsers() async {
    emit(RegisterUserLoading());

    try {
      final result = await _databaseHelper.queryAllUsers();
      emit(RegisterUserLoaded(users: result));
    } catch (e) {
      emit(RegisterUserError(e.toString()));
    }
  }
}

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
  CameraService get cameraService => _cameraService;

  final FaceDetectorService _faceDetectorService;
  FaceDetectorService get faceDetectorService => _faceDetectorService;

  final MLService _mlService;
  MLService get mlService => _mlService;

  final DatabaseHelper _databaseHelper;
  DatabaseHelper get databaseHelper => _databaseHelper;

  RegisterUserCubit(
    this._cameraService,
    this._faceDetectorService,
    this._mlService,
    this._databaseHelper,
  ) : super(RegisterUserInitial());

  Future<void> initializeServices() async {
    emit(RegisterUserLoading());
    await _cameraService.initialize();
    _faceDetectorService.initialize();
    emit(RegisterUserHasInitialized());
    emit(RegisterUserLoaded());
  }

  Future<void> insertUser(User user) async {
    await databaseHelper.insert(user);
  }

  void disposeServices() {
    emit(RegisterUserLoading());
    _cameraService.dispose();
    _faceDetectorService.dispose();
    _mlService.dispose();
    emit(RegisterUserInitial());
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../db/databse_helper.dart';
import '../../services/face_detector_service.dart';
import '../../services/ml_service.dart';

part 'home_user_state.dart';

class HomeUserCubit extends Cubit<HomeUserState> {
  final MLService _mlService;
  MLService get mlService => _mlService;

  final FaceDetectorService _faceDetectorService;
  FaceDetectorService get faceDetectorService => _faceDetectorService;

  final DatabaseHelper _databaseHelper;
  DatabaseHelper get databaseHelper => _databaseHelper;

  HomeUserCubit(
    this._mlService,
    this._faceDetectorService,
    this._databaseHelper,
  ) : super(HomeUserInitial());

  Future<void> initializeServices() async {
    emit(HomeUserLoading());
    await _mlService.initialize();
    _faceDetectorService.initialize();
    emit(HomeUserHasInitialized());
  }

  disposeServices() {
    emit(HomeUserLoading());
    _mlService.dispose();
    _faceDetectorService.dispose();
    emit(HomeUserInitial());
  }

  deleteAllUsers() {
    _databaseHelper.deleteAll();
  }
}

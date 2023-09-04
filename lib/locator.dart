import 'package:fr_app/db/databse_helper.dart';
import 'package:get_it/get_it.dart';

import 'services/camera.service.dart';
import 'services/face_detector_service.dart';
import 'services/ml_service.dart';

final locator = GetIt.instance;

void setupServices() {
  locator.registerLazySingleton(() => CameraService());
  locator.registerLazySingleton(() => FaceDetectorService());
  locator.registerLazySingleton(() => MLService());
  locator.registerLazySingleton(() => DatabaseHelper());
}

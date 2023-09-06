import 'package:fr_app/models/user_model.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class MlUserModel {
  MlUserModel({
    required this.face,
    required this.user,
  });
  final Face face;
  final User user;
}

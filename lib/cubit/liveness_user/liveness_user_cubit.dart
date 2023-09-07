import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'liveness_user_state.dart';

class LivenessUserCubit extends Cubit<LivenessUserState> {
  LivenessUserCubit() : super(LivenessUserInitial());
}

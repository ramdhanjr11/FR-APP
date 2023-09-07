part of 'register_user_cubit.dart';

@immutable
sealed class RegisterUserState extends Equatable {}

final class RegisterUserInitial extends RegisterUserState {
  @override
  List<Object?> get props => [];
}

final class RegisterUserLoading extends RegisterUserState {
  @override
  List<Object?> get props => [];
}

final class RegisterUserLoaded extends RegisterUserState {
  final List<User>? users;
  RegisterUserLoaded({this.users});

  @override
  List<Object?> get props => [users];
}

final class RegisterUserError extends RegisterUserState {
  final String message;
  RegisterUserError(this.message);

  @override
  List<Object?> get props => [message];
}

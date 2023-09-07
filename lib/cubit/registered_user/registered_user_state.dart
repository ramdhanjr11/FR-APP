part of 'registered_user_cubit.dart';

@immutable
sealed class RegisteredUserState extends Equatable {}

final class RegisteredUserInitial extends RegisteredUserState {
  @override
  List<Object?> get props => [];
}

final class RegisteredUserLoading extends RegisteredUserState {
  @override
  List<Object?> get props => [];
}

final class RegisteredUserLoaded extends RegisteredUserState {
  final List<User>? users;
  RegisteredUserLoaded({this.users});

  @override
  List<Object?> get props => [users];
}

final class RegisteredUserError extends RegisteredUserState {
  final String message;
  RegisteredUserError(this.message);

  @override
  List<Object?> get props => [message];
}

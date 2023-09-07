part of 'home_user_cubit.dart';

sealed class HomeUserState extends Equatable {
  const HomeUserState();

  @override
  List<Object> get props => [];
}

final class HomeUserInitial extends HomeUserState {}

final class HomeUserLoading extends HomeUserState {}

final class HomeUserHasInitialized extends HomeUserState {}

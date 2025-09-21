import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}
class RegisterRequested extends AuthEvent {
  final String email;
  final String username;
  final String password;
  final VoidCallback? onSuccess;
  RegisterRequested({
    required this.email,
    required this.password,
    required this.username,
    this.onSuccess,
  });

  @override
  List<Object?> get props => [email, password, username];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

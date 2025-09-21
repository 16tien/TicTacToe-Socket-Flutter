import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(const AuthState()) {
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<RegisterRequested>(_onRegister);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final user = await repository.login(event.email, event.password);
      emit(state.copyWith(isLoading: false, user: user));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await repository.logout();
    emit(const AuthState());
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event, Emitter<AuthState> emit) async {
    final loggedIn = await repository.hasToken();
    if (loggedIn) {
      final user = await repository.getProfile();
      emit(state.copyWith(user: user));
    } else {
      emit(const AuthState());
    }
  }

  Future<void> _onRegister(
      RegisterRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await repository.register(
        event.email,
        event.password,
        event.username,
      );
      emit(state.copyWith(isLoading: false));
      event.onSuccess?.call();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}

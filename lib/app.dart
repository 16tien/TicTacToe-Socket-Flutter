import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:xo/features/auth/presentation/pages/register_page.dart';
import 'package:xo/features/room/presentation/bloc/room_bloc.dart';
import 'core/network/dio_client.dart';
import 'core/network/ws_client.dart';
import 'core/theme/app_themes.dart';
import 'features/auth/data/models/user_local_storage.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/auth/presentation/blocs/auth_event.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/onboard_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/game/presentation/pages/online_lobby_page.dart';
import 'features/room/presentation/bloc/room_event.dart';
import 'features/room/presentation/pages/home_page.dart';
import 'features/room/presentation/pages/room_list_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = const FlutterSecureStorage();
    final dioClient = DioClient(storage: storage);
    final userLocalStorage = UserLocalStorage();
    final authRepository = AuthRepository(dioClient,userLocalStorage);
    final ws = WSClient(url: 'ws://10.0.2.2:3050');
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserLocalStorage>.value(value: userLocalStorage),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(authRepository)..add(CheckAuthStatus()),
          ),
          BlocProvider<RoomBloc>(
            create: (_) => RoomBloc(ws: ws)..add(FetchRooms()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Note App with Auth",
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashPage(),
            '/login': (context) => const LoginPage(),
            '/onboard' : (context) => const OnboardingPage(),
            '/home' : (context) => const HomePage(),
            '/register': (context) => const RegisterPage(),
            '/online-lobby' : (context) => const OnlineLobbyPage(),
            '/room-list' : (context) => const RoomListPage(),
          },
        ),
      ),
    );
  }
}

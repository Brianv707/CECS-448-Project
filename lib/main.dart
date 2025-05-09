import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pokemon_card_tracker/services/auth_service.dart';
import 'package:pokemon_card_tracker/screens/welcome_screen.dart';
import 'package:pokemon_card_tracker/screens/login_screen.dart';
import 'package:pokemon_card_tracker/screens/signup_screen.dart';
import 'package:pokemon_card_tracker/screens/home_screen.dart';
import 'package:pokemon_card_tracker/screens/set_detail_screen.dart';

void main() {
  runApp(const PokemonCardTracker());
}

class PokemonCardTracker extends StatelessWidget {
  const PokemonCardTracker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 851), // iPhone 14 Pro screen size
      minTextAdapt: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthService()),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Pokemon Card Tracker',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            routerConfig: _router,
          ),
        );
      },
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/set/:setId',
      builder: (context, state) {
        final setId = state.pathParameters['setId']!;
        return SetDetailScreen(setId: setId);
      },
    ),
  ],
);
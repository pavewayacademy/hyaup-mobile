import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_preferences.dart';
import 'firebase_options.dart';
import 'presentation/screens/employer/employer_auth_screen.dart';
import 'presentation/screens/employer/employer_dashboard_screen.dart';
import 'presentation/screens/intro/intro_screen.dart';
import 'presentation/screens/main_navigation_screen.dart';
import 'repository/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization warning: $e");
  }

  runApp(const HyaUpApp());
}

class HyaUpApp extends StatelessWidget {
  const HyaUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HyaUp - AI Job Search Cameroon',
      theme: AppTheme.lightTheme,
      home: const AppRootScreen(),
    );
  }
}

class AppRootScreen extends StatefulWidget {
  const AppRootScreen({super.key});

  @override
  State<AppRootScreen> createState() => _AppRootScreenState();
}

class _AppRootScreenState extends State<AppRootScreen> {
  final AuthRepository _authRepo = AuthRepository();

  Future<Widget> _determineInitialRoute() async {
    final bool hasSeenIntro = await AppPreferences.hasSeenIntro();
    if (!hasSeenIntro) {
      return const IntroScreen();
    }

    final String? role = await AppPreferences.getUserRole();
    if (role == "employer") {
      final bool isAuth = _authRepo.isAuthenticated;
      if (isAuth) {
        return const EmployerDashboardScreen();
      } else {
        return const EmployerAuthScreen(isSignUp: false);
      }
    }

    // Default: Job Seeker / Professional -> Discover Job Search
    return const MainNavigationScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _determineInitialRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return snapshot.data ?? const IntroScreen();
      },
    );
  }
}
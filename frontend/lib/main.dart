import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/theme_provider.dart';
import 'package:flutter_demo/pages/auth_page.dart';
import 'package:flutter_demo/pages/sign_in.dart';
import 'package:flutter_demo/pages/map_page.dart';
import 'package:flutter_demo/pages/sign_up.dart';
import 'package:flutter_demo/pages/splash_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          ThemeProvider(ThemeData.light()), // Default to light theme
      child: MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(ThemeData.light()), // Set the initial theme
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            theme: themeProvider.getTheme(),
            home: SplashPage(),
            routes: {
            '/loginPage': (context) => LoginPage(),
            '/mapsPage': (context) => MapPage(),
            '/authPage': (context) => AuthPage(),
            '/signInPage': (context) => SignInPage()
      },
          );
        },
      ),
    );
  }
}

/*
class AuthStateSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashPage();
        } else {
          print('User is logged in');
          return AuthPage();
        }
      },
    );
  }
}
*/

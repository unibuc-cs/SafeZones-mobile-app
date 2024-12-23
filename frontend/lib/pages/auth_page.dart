import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/sign_in.dart';
import 'package:flutter_demo/pages/map_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Utilizatorul este autentificat
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null && user.emailVerified) {
                print(user.uid);
                return MapPage();
              } 
            }
            return LoginPage();
          }

      ),
    );
  }
}

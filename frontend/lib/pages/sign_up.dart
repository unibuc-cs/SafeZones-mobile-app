import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_demo/components/button_sign_in.dart';
import 'package:flutter_demo/components/button_sign_up.dart';
import 'package:flutter_demo/components/square_logo.dart';
import 'package:flutter_demo/components/text_field.dart';
import 'package:flutter_demo/pages/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class SignInPage extends StatelessWidget {
  SignInPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  Future<void> signMeUp(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (userCredential != null && userCredential.user != null) {
        // Send mail verification
        await userCredential.user!.sendEmailVerification();

        // ------------------ save into db -----------------------------

        final response = await http.get(
          Uri.parse('$baseURL/users/${userCredential.user!.uid}'),
        );

        if (response.statusCode == 200) {
          print('User already exists in the database');
        } else {
          final response = await http.post(
            Uri.parse('$baseURL/users/add'),
            headers: <String, String>{
              'Content-Type':
                  'application/x-www-form-urlencoded', // Use form data
            },
            body: {
              'name': usernameController.text,
              'email': emailController.text,
              'id': userCredential.user!.uid,
            },
          );
          if (response.statusCode == 200) {
            print('User added successfully');
          } else {
            print('Failed to add user');
          }
        }

        // -----------------------------------------------------------------------

        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Please verify your email, then Sign In!'),
              content: Text(
                  'An email verification link has been sent to your email address. Please verify your email before proceeding.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        await Future.delayed(Duration(seconds: 5));
        Navigator.pushNamed(context, '/loginPage');
      } else {
        // Dacă userCredential sau userCredential.user este null, afișați o alertă pentru a indica o eroare neașteptată
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(
                  'An unexpected error occurred while creating the account.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else {
        errorMessage = 'An error occurred: ${e.message}';
      }
      // Show alert error
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An unexpected error occurred: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void signUpWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount?.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken);

    UserCredential result = await firebaseAuth.signInWithCredential(credential);

    User? user = result.user;
    if (result != null) {
      print('ok');
      Navigator.pushNamed(context, '/mapsPage');
    }
  }

  void checkPasswordCriteria(BuildContext context) {
    String password = passwordController.text.trim();

    RegExp uppercaseRegex = RegExp(r'[A-Z]');
    RegExp digitRegex = RegExp(r'[0-9]');
    RegExp specialCharacterRegex = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');

    bool hasUppercase = uppercaseRegex.hasMatch(password);
    bool hasDigit = digitRegex.hasMatch(password);
    bool hasSpecialCharacter = specialCharacterRegex.hasMatch(password);

    if (hasUppercase && hasDigit && hasSpecialCharacter) {
      signMeUp(context);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Eroare'),
          content: Text(
              'Password must contain at least one uppercase letter, one number, and one special character.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop(); // Navigarea înapoi
                  },
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 100),

                        const SizedBox(height: 25),

                        // mail
                        MyTextField(
                          controller: emailController,
                          hintText: 'Email',
                          obscureText: false,
                        ),
                        const SizedBox(height: 10),

                        // username
                        MyTextField(
                          controller: usernameController,
                          hintText: 'Username',
                          obscureText: false,
                        ),
                        const SizedBox(height: 10),

                        // Password
                        MyTextField(
                          controller: passwordController,
                          hintText: 'Password',
                          obscureText: true,
                        ),

                        const SizedBox(height: 25),

                        Container(
                          padding: const EdgeInsets.all(25),
                          margin: const EdgeInsets.symmetric(horizontal: 25),
                          child: ButtonSignUp(
                            onTap: () => checkPasswordCriteria(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

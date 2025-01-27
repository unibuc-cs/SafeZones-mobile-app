import 'package:flutter/material.dart';

class ButtonSignIn extends StatelessWidget {
  final Function()? onTap; // Funcția care va fi apelată când butonul este apăsat

  const ButtonSignIn({Key? key, required this.onTap}) : super(key: key);

  @override 
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black,
        elevation: 4, // Aici setezi elevația pentru a obține efectul de apăsare
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(25),
            margin: const EdgeInsets.symmetric(horizontal: 25),
            child: Center(
              child: Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

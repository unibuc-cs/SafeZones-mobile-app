import 'package:flutter/material.dart';

class ButtonSignUp extends StatelessWidget {
  final Function()? onTap; // Funcția care va fi apelată când butonul este apăsat

  const ButtonSignUp({Key? key, required this.onTap}) : super(key: key);

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
                "Sign Up",
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

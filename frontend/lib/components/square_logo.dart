import 'package:flutter/material.dart';

class SquareLogo extends StatelessWidget {
  //final String imagePath;
  //final Function()? onTap;

  const SquareLogo({
    Key? key,
    //required this.imagePath,
    //required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink(
      //onTap: onTap,
      //borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.4),
        ),
        child: Image.asset(
          'assets/images/google_logo.png',
          height: 40,
        ),
      ),
    );
  }
}

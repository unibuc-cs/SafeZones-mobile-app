import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_demo/pages/sign_in.dart';


class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Wait 3 seconds before switch activities
    Timer(Duration(seconds: 3), () {
      Navigator.pushNamed(context, '/authPage');
    });

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 26, 24, 24),
      body: Align(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Animation
            Positioned(
              child: Container(
                child: FadeIn(
                  duration: Duration(milliseconds: 1500),
                  child: SlideInUp(
                    from: 100,
                    child: Image.asset(
                      'assets/images/city_map.png',
                      width: 400,
                      height: 240,
                    ),
                  ),
                ),
              ),
            ),
            
            Positioned(
              top: 0,
              child: Container(
                child: BounceInDown(
                  from: 200,
                  delay: Duration(milliseconds: 1000),
                  child: RotationTransition(
                    turns: AlwaysStoppedAnimation(1),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
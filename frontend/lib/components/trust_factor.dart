import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme_provider.dart';

class ModernTrustFactor extends StatelessWidget {
  final String event;
  final String userLevel;

  ModernTrustFactor({required this.event, required this.userLevel});

  @override
  Widget build(BuildContext context) {

    void toggleTheme(bool isDark) {
      Provider.of<ThemeProvider>(context, listen: false).setTheme(
        isDark ? ThemeData.dark() : ThemeData.light(),
      );
    }
    
    Color textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Event Text
          Expanded(
            child: Text(
              event,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 10),

          // Trust Factor
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < int.parse(userLevel) ? Icons.star : Icons.star_border,
                color: Colors.amber,
              );
            }),
          ),
        ],
      ),
    );
  }
}

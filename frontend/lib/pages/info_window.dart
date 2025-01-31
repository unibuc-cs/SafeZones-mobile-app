import 'package:flutter/material.dart';

class CustomInfoWindow extends StatelessWidget {
  final String description;
  final String timeAgo;

  CustomInfoWindow({required this.description, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.indigo.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'RobotoMono', // Font modern
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.white70,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                timeAgo,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontFamily: 'RobotoMono', // Font modern
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

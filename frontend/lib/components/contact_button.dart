import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_keys.dart'; // Ensure correct import

class ContactButton {
  static void showContactSupportDialog(BuildContext context, String userEmail) {
    final TextEditingController _problemController = TextEditingController();
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Contact Support',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.4,
            child: TextField(
              controller: _problemController,
              decoration: InputDecoration(
                hintText: 'Describe your issue...',
                hintStyle: TextStyle(color: textColor.withOpacity(0.7)),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 10,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final message = _problemController.text;
                if (message.isNotEmpty) {
                  try {
                    final response = await http.post(
                      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
                      headers: {
                        'Content-Type': 'application/json',
                        'origin': 'http://localhost',
                        'User-Agent': 'flutter',
                      },
                      body: jsonEncode({
                        'service_id': ApiKeys.serviceId,
                        'template_id': ApiKeys.templateId,
                        'user_id': ApiKeys.userId,
                        'template_params': {
                          'user_email': userEmail,
                          'message': message,
                        }
                      }),
                    );

                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email sent successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${response.body}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Connection error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text(
                'Submit',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

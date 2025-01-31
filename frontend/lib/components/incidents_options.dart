import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OptionsPage extends StatefulWidget {
  @override
  _OptionsPageState createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  final List<String> events = [
    'Assault',
    'Harassment',
    'Pickpocketing',
    'Robbery',
    'Suspicious Activity',
    'Public Intoxication',
    'Stray Animals',
    'Roof Hazard'
  ];

  final Map<String, String> eventCategories = {
    'Assault': 'Hard',
    'Robbery': 'Hard',
    'Suspicious Activity': 'Hard',
    'Harassment': 'Medium',
    'Pickpocketing': 'Medium',
    'Public Intoxication': 'Medium',
    'Stray Animals': 'Medium',
    'Roof Hazard': 'Medium',
  };

  String selectedEvent = "";
  String selectedCategory = "";
  TextEditingController descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Options'),
      ),
      body: ListView(
        children: [
          // Listă de evenimente
          for (String event in events)
            ListTile(
              title: Text(event),
              tileColor:
                  selectedEvent == event ? Colors.blue.withOpacity(0.3) : null,
              onTap: () {
                setState(() {
                  selectedEvent = event;
                  selectedCategory = eventCategories[event] ?? "";
                });
              },
            ),
          // Câmp pentru introducerea descrierii
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: 'Enter description',
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(
                    30), // Limita de 30 de caractere
              ],
            ),
          ),
          // Buton pentru confirmare
          ElevatedButton(
            onPressed: () {
              _handleOptionSelected(context);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red, // Culorea textului
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Bordura rotunjită
              ),
            ),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _handleOptionSelected(BuildContext context) {
    // Întoarceți datele către pagina anterioară
    Navigator.pop(
      context,
      {
        'event': selectedEvent,
        'category': selectedCategory,
        'description': descriptionController.text,
      },
    );
  }
}

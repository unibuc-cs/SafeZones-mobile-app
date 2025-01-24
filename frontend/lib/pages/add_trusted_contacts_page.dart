import 'package:flutter/material.dart';

class AddTrustedContactsPage extends StatelessWidget {
  const AddTrustedContactsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Trusted Contacts'),
      ),
      body: Center(
        child: Text(
          'This is the Add Trusted Contacts page.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

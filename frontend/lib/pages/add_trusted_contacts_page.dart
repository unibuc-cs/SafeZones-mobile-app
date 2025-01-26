import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter_demo/pages/constants.dart';

class AddTrustedContactsPage extends StatefulWidget {
  const AddTrustedContactsPage({Key? key}) : super(key: key);

  @override
  _AddTrustedContactsPageState createState() => _AddTrustedContactsPageState();
}

class _AddTrustedContactsPageState extends State<AddTrustedContactsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];
  String? _loggedInUserId;
  List<Map<String, dynamic>> _addedContacts = []; // Contacts I added
  List<Map<String, dynamic>> _addedByContacts = [];

  @override
  void initState() {
    super.initState();
    _fetchLoggedInUserId();
    _fetchUsers();
    _fetchAddedContacts();
    _fetchAddedByContacts();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch the logged-in user's ID
  void _fetchLoggedInUserId() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _loggedInUserId = user.uid;
      });
    }
  }

  // Fetch users from the backend
  Future<void> _fetchUsers() async {
    final response = await http.get(Uri.parse('$baseURL/users/all'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _allUsers = data
            .where((user) =>
                user['id'] != _loggedInUserId && user['emailVerified'] == true)
            .toList();
        _filteredUsers = _allUsers;
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> _fetchAddedContacts() async {
    if (_loggedInUserId == null) return;

    final response = await http.get(
      Uri.parse('$baseURL/users/contacts/added-contacts/$_loggedInUserId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _addedContacts = data
            .map((contact) => {
                  'username': contact['username'],
                  'email': contact['email'],
                  'id': contact['id'],
                })
            .toList();
      });
    } else {
      throw Exception('Failed to load added contacts');
    }
  }

  // Fetch users who added the logged-in user
  Future<void> _fetchAddedByContacts() async {
    if (_loggedInUserId == null) return;

    final response = await http.get(
      Uri.parse('$baseURL/users/contacts/added-by-contacts/$_loggedInUserId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _addedByContacts = data
            .map((contact) => {
                  'username': contact['username'],
                  'email': contact['email'],
                  'id': contact['id'],
                })
            .toList();
      });
    } else {
      throw Exception('Failed to load contacts added by users');
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers
          .where((user) =>
              user['username']!.toLowerCase().contains(query) ||
              user['email']!.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _removeContact(String contactId) async {
    if (_loggedInUserId == null) {
      return;
    }
    final String url =
        '$baseURL/users/contacts/remove-contact/$_loggedInUserId/$contactId';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await _fetchAddedContacts();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contact removed successfully!')),
        );
      } else if (response.statusCode == 409) {
        // Contact already removed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This contact has already been removed.')),
        );
      } else if (response.statusCode == 404) {
        // User or contact not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('One of the users could not be found.')),
        );
      } else {
        // Other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove contact.')),
        );
      }
    } catch (error) {
      // Network or other unexpected errors
      print("Error occurred while removing contact: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  Future<void> _addContact(dynamic contact) async {
    if (_loggedInUserId == null) {
      return;
    }

    final String contactId = contact['id']!;
    final String url =
        '$baseURL/users/contacts/add-contact/$_loggedInUserId/$contactId';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await _fetchAddedContacts();
        await _fetchAddedByContacts();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contact added successfully!')),
        );
      } else if (response.statusCode == 409) {
        // Contact already added
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This contact has already been added.')),
        );
      } else if (response.statusCode == 404) {
        // User or contact not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('One of the users could not be found.')),
        );
      } else {
        // Other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add contact.')),
        );
      }
    } catch (error) {
      // Network or other unexpected errors
      print("Error occurred while adding contact: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  // Add these variables to your state class
  bool _showExistingContacts = true;

// Updated build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Trusted Contacts'),
      ),
      body: Column(
        children: [
          // Top half - Search and All Users
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return ListTile(
                        title: Text(user['username']!),
                        subtitle: Text(user['email']!),
                        trailing: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            _addContact(user);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Bottom half - Toggle and Lists
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Toggle Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () =>
                          setState(() => _showExistingContacts = true),
                      child: Text(
                        'Added users',
                        style: TextStyle(
                          color:
                              _showExistingContacts ? Colors.blue : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          setState(() => _showExistingContacts = false),
                      child: Text(
                        'Added by',
                        style: TextStyle(
                          color: !_showExistingContacts
                              ? Colors.blue
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                // Dynamic List
                Expanded(
                  child: _showExistingContacts
                      ? _buildContactsList(_addedContacts)
                      : _buildContactsList(_addedByContacts),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Helper method to build contact lists
  Widget _buildContactsList(List<Map<String, dynamic>> contacts) {
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          title: Text(contact['username']!),
          subtitle: Text(contact['email']!),
          trailing: _showExistingContacts
              ? IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => (_removeContact(contact['id']!)),
                )
              : IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => (_addContact(contact)),
                ),
        );
      },
    );
  }
}

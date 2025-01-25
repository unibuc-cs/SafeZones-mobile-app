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
  List<Map<String, String>> _allUsers = [];
  List<Map<String, String>> _filteredUsers = [];
  String? _loggedInUserId;

  @override
  void initState() {
    super.initState();
    _fetchLoggedInUserId();
    _fetchUsers();
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
            .map((user) => {
                  'username': user['username'].toString(),
                  'email': user['email'].toString(),
                })
            .toList();
        _filteredUsers = _allUsers;
      });
    } else {
      throw Exception('Failed to load users');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Trusted Contacts'),
      ),
      body: Column(
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
            child: _filteredUsers.isEmpty
                ? Center(child: Text('No users found'))
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return ListTile(
                        title: Text(user['username'] ?? 'N/A'),
                        subtitle: Text(user['email'] ?? 'N/A'),
                        trailing: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            _addToTrustedContacts(user);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _addToTrustedContacts(Map<String, String> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $user to trusted contacts'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

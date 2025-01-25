import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_demo/components/point.dart';
import 'package:flutter_demo/components/theme_provider.dart';
import 'package:flutter_demo/pages/constants.dart';
import 'package:provider/provider.dart';
import '../pages/add_trusted_contacts_page.dart';
import 'contact_button.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

class NavBar extends StatefulWidget {
  final Function(bool) toggleTheme;
  final List<Point> nearbyPoints;

  NavBar({Key? key, required this.toggleTheme, required this.nearbyPoints})
      : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late String _username = '';
  late String _userEmail = '';
  late int _userLevel = 1;
  late int _userPoints = 0;
  double _userLatitude = 0.0;
  double _userLongitude = 0.0;
  bool _isLoading = true;
  String? _errorMessage;
  File? _profileImage;
  late String userId;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userId = user.uid;
        var userData = await Future.wait([
          fetchUsername(userId),
          fetchUserLevel(userId),
          fetchUserPoints(userId),
          fetchProfileImage(),
          fetchEmail(userId)
        ]);
        setState(() {
          _username = userData[0].toString();
          _userLevel = int.parse(userData[1].toString());
          _userPoints = int.parse(userData[2].toString());
          _profileImage = File(userData[3].toString());
          _userEmail = userData[4].toString();
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      print(pickedFile.path);
      _uploadProfileImage(pickedFile.path);
    }
  }

  Future<void> _uploadProfileImage(String path) async {
    try {
      final response = await http.post(
        Uri.parse('$baseURL/users/update-profile-image/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded', // Use form data
        },
        body: {'imagePath': path},
      );
    } catch (e) {
      print('Failed to upload profile image: $e');
    }
  }

  Future<String> fetchProfileImage() async {
    final response = await http.get(
      Uri.parse('$baseURL/users/get-profile-image/$userId'),
    );
    if (response.statusCode == 200) {
      return response.body;
    }
    return "";
  }

  Future<String> fetchUsername(String userId) async {
    if (userId.isNotEmpty) {
      final response = await http.get(Uri.parse('$baseURL/users/$userId'));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to fetch username');
      }
    }
    return "";
  }

   Future<String> fetchEmail(String userId) async {
      if (userId.isNotEmpty) {
        final response = await http.get(Uri.parse('$baseURL/users/mail/$userId'));
        if (response.statusCode == 200) {
          return response.body;
        } else {
          throw Exception('Failed to fetch username');
        }
      }
      return "";
  }
  }

  Future<int> fetchUserLevel(String userId) async {
    if (userId.isNotEmpty) {
      final response = await http.get(Uri.parse('$baseURL/users/level/$userId'),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        return int.parse(response.body); // Parse the integer from response body
      } else {
        throw Exception('Failed to fetch user level');
      }
    }
    return 1; // Default to level 1 if not fetched
  }

  Future<int> fetchUserPoints(String userId) async {
    if (userId.isNotEmpty) {
      final response = await http.get(
          Uri.parse('$baseURL/users/points/$userId'),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        return int.parse(response.body); // Parse the integer from response body
      } else {
        throw Exception('Failed to fetch user points');
      }
    }
    return 0; // Default to 0 points if not fetched
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final c = cos;
    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000; // Distance in meters
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _userLatitude = position.latitude;
        _userLongitude = position.longitude;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      return Center(
        child:
            Text('Error: $_errorMessage', style: TextStyle(color: textColor)),
      );
    }

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UserAccountsDrawerHeader(
            accountName: Row(
              children: [
                Text('Hello, ', style: TextStyle(color: textColor)),
                SizedBox(width: 5),
                Text(_username,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
            accountEmail: null,
            currentAccountPicture: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : NetworkImage(
                        FirebaseAuth.instance.currentUser?.photoURL ??
                            'https://via.placeholder.com/150') as ImageProvider,
              ),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade100, Colors.blue.shade600],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.star, color: Colors.yellow),
            title: Text('Level $_userLevel',
                style:
                    TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            onTap: () => null,
          ),
          Divider(indent: 16, endIndent: 16),
          ListTile(
            leading:
                Icon(Icons.filter_center_focus_rounded, color: Colors.green),
            title: Text(
                'Reward points: $_userPoints${_userLevel == 5 ? "" : "/${_userLevel * 10}"}',
                style:
                    TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            onTap: () => null,
          ),
          Divider(indent: 16, endIndent: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.nearbyPoints.length,
              itemBuilder: (context, index) {
                Point point = widget.nearbyPoints[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                      color:
                          point.category == 'Hard' ? Colors.red : Colors.yellow,
                      width: 2.0,
                    ),
                  ),
                  margin: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          point.event,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Description: ' + (point.description ?? ''),
                          style: TextStyle(color: textColor),
                        ),
                        onTap: () {},
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          _calculateDistance(
                                      _userLatitude,
                                      _userLongitude,
                                      double.parse(point.latitude),
                                      double.parse(point.longitude))
                                  .floor()
                                  .toString() +
                              ' meters away',
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ListTile(
            title: Text('Dark Mode',
                style:
                    TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            trailing: Switch(
              activeColor: Colors.white,
              inactiveThumbColor: Colors.white,
              activeTrackColor: Colors.green,
              inactiveTrackColor: const Color.fromARGB(255, 198, 195, 195),
              value:
                  Provider.of<ThemeProvider>(context).getTheme().brightness ==
                      Brightness.dark,
              onChanged: (bool value) {
                widget.toggleTheme(value);
              },
            ),
            onTap: () => null,
          ),
          Divider(indent: 16, endIndent: 16),
          SafeArea(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.contacts, color: Colors.blue),
                  title: Text('Trusted Contacts',
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.bold)),
                  onTap: () {
                    // Navigate to the Add Trusted Contacts page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTrustedContactsPage(),
                      ),
                    );
                  },
                ),
                ListTile(
            title: Text('Contact Support',
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold
                )),
            leading: Icon(Icons.help_outline, color: Colors.blue),
            onTap: () => ContactButton.showContactSupportDialog(context, _userEmail),
          ),
                ListTile(
                  title: Text('Exit',
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.bold)),
                  leading: Icon(Icons.exit_to_app, color: Colors.red),
                  onTap: () => _signMeOut(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _signMeOut(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Logout"),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        );
      },
    );
  }
}

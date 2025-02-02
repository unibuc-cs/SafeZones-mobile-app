import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/components/incidents_options.dart';
import 'package:flutter_demo/components/navBar.dart';
import 'package:flutter_demo/pages/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../components/point.dart';
import '../pages/map_page.dart';
import 'trust_factor.dart';

class InfoPanel extends StatefulWidget {
  final Point point;
  final VoidCallback onClose;

  InfoPanel({Key? key, required this.point, required this.onClose})
      : super(key: key);

  @override
  _InfoPanelState createState() => _InfoPanelState();
}

class _InfoPanelState extends State<InfoPanel> {
  int _voteCount = 0;
  String? _currentUserId;
  String? _userName = '';
  String? _userLevel = '';
  bool _isLikedByUser = false;  
  bool isChatOpen = false;

  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  
  String _userCurrentName = '';

  @override
  void initState() {
    super.initState();
    _voteCount = widget.point.votes;
    _fetchCurrentVotes();
    _fetchCurrentUserId();
    _fetchUserName();
    _fetchUserLevel();
    _fetchCurrentUserName();
    _pointLikedByUser();
    _getMessages();
  }

  // Fetch the current user ID from Firebase Auth
  Future<void> _fetchCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

 Future<void> _getMessages() async {
    List<ChatMessage> fetchedMessages = await fetchMessages(widget.point.id);
    print(widget.point.id);
    setState(() {
      _messages.clear();
      _messages.addAll(fetchedMessages);
    });
  }
  // Fetch the user name from the server
  Future<void> _fetchUserName() async {
    try {
      final response = await http.get(
        Uri.parse('${baseURL}/users/${widget.point.userId}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _userName = response.body;
        });
      } else {
        throw Exception('Failed to load user name');
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  Future<void> _fetchCurrentUserName() async {
    try {
      final response = await http.get(
        Uri.parse('${baseURL}/users/${_currentUserId}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _userCurrentName = response.body;
        });
      } else {
        throw Exception('Failed to load user name');
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  // Fetch the user level from the server
  Future<void> _fetchUserLevel() async {
    try {
      final response = await http.get(
        Uri.parse('${baseURL}/users/level/${widget.point.userId}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _userLevel = response.body;
        });
      } else {
        throw Exception('Failed to load user level');
      }
    } catch (e) {
      print('Error fetching user level: $e');
    }
  }

  // Format the timestamp to show how long ago the point was created
  String _formatTimeAgo(DateTime date) {
    final duration = DateTime.now().difference(date);

    if (duration.inDays > 0) {
      return '${duration.inDays} days ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Fetch the current number of votes for the point
  Future<void> _fetchCurrentVotes() async {
    try {
      final response = await http.get(
        Uri.parse('${baseURL}/points/votes/${widget.point.id}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _voteCount = int.parse(response.body);
        });
      } else {
        throw Exception('Failed to load votes');
      }
    } catch (e) {
      print('Error fetching votes: $e');
    }
  }

  // Increment the votes for the point
  Future<void> _incrementVotes() async {
    _isLikedByUser = true;
    try {
      final response = await http.post(
        Uri.parse(
            '$baseURL/points/incrementVotes/${widget.point.id}/${_currentUserId}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        _incrementRewardPoints();
        _fetchCurrentVotes();
      } else {
        throw Exception(
            'Failed to increment votes and reward points: ${response.body}');
      }
    } catch (e) {
      print('Error incrementing votes: $e');
    }
  }

  // Increment the reward points for the user who created the point
  Future<void> _incrementRewardPoints() async {
    try {
      final response = await http.put(
        Uri.parse('$baseURL/users/incrementPoints/${widget.point.userId}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print('Reward points incremented successfully.');
        _fetchCurrentVotes();
      } else {
        throw Exception('Failed to increment reward points: ${response.body}');
      }
    } catch (e) {
      print('Error incrementing reward points: $e');
    }
  }

  // Check if the current user has liked the point
  Future<void> _pointLikedByUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseURL/points/liked-by/${widget.point.id}/${_currentUserId}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print(response.body);
        _isLikedByUser = response.body == 'true' ? true : false;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Fetch all points from the backend
  Future<List<Point>> _getMarkersFromBackend() async {
    final response = await http.get(Uri.parse('${baseURL}/points/all'));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((pointJson) => Point.fromJson(pointJson)).toList();
    } else {
      throw Exception('Failed to load points');
    }
  }

  @override
Widget build(BuildContext context) {
  Color textColor = Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : Colors.black;

  // Check if the point belongs to the current user
  bool isCurrentUserPoint = _currentUserId == widget.point.userId;

  return Stack(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: isChatOpen ? 500 : 300,
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (_userLevel != '') ModernTrustFactor(event: widget.point.event, userLevel: _userLevel!),
                    SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.description, color: textColor),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Description: ${widget.point.description}",
                            style: TextStyle(fontSize: 16, color: textColor),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: textColor),
                        SizedBox(width: 8),
                        Text(
                          _formatTimeAgo(widget.point.timestamp),
                          style: TextStyle(fontSize: 16, color: textColor),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.thumb_up, color: textColor),
                        SizedBox(width: 8),
                        Text(
                          "Likes: $_voteCount",
                          style: TextStyle(fontSize: 16, color: textColor),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ElevatedButton.icon(
                          onPressed: _incrementVotes,
                          icon: Icon(
                            _isLikedByUser ? Icons.thumb_up : Icons.thumb_up_off_alt,
                            color: Colors.white,
                          ),
                          label: Text(
                            _isLikedByUser ? 'Liked' : 'Like',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isLikedByUser ? Colors.green : Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isChatOpen = !isChatOpen;
                            });
                          },
                          icon: Icon(isChatOpen ? Icons.close : Icons.chat, color: Colors.white),
                          label: Text(
                            isChatOpen ? 'Close Chat' : 'Open Chat',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 30, 82, 238),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          ),
                        ),
                      ],
                    ),
                    if (isChatOpen) ...[
                      Divider(),
                      Text(
                        "Chat Section",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 200,
                        child: ListView.builder(
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isCurrentUserMessage = message.username == _userName;
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isCurrentUserMessage ? Colors.blue[50] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: isCurrentUserMessage
                                    ? Border.all(color: Colors.blue, width: 2)
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isCurrentUserMessage ? Colors.blue : Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(message.content),
                                  SizedBox(height: 4),
                                  Text(
                                    _formatTimeAgo(message.timestamp),
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: "Type your message",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                onSubmitted: _sendMessage,
                              ),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _sendMessage(_messageController.text),
                              child: Icon(Icons.send),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
}

Future<List<ChatMessage>> fetchMessages(int chatId) async {
  final response = await http.get(
    Uri.parse('${baseURL}/chat/get/$chatId'),
  );

  if (response.statusCode == 200) {
    List<dynamic> messages = jsonDecode(response.body);
    return messages.map((msg) => ChatMessage(
      content: msg['content'] as String,
      username: msg['username'] as String,
      timestamp: DateTime.parse(msg['timestamp']),  // Parsează timestamp-ul
    )).toList();
  } else {
    throw Exception('Failed to load messages');
  }
}
void _sendMessage(String message) {
  if (message.isEmpty) return;

  DateTime now = DateTime.now(); // Timestamp-ul mesajului
  setState(() {
    _messages.add(new ChatMessage(content: message, username: _userCurrentName, timestamp: now));
  });

  _messageController.clear(); // Curăță câmpul de text

  // Trimiterea mesajului către backend
  sendMessage(message, _currentUserId ?? "", widget.point.id, now);
}

Future<void> sendMessage(String content, String userId, int chatId, DateTime timestamp) async {
  final response = await http.post(
    Uri.parse('${baseURL}/chat/add'),
    headers: <String, String>{'Content-Type': 'application/json'},
    body: jsonEncode(<String, String>{
      "content": content,
      "userId": userId,
      "chatId": chatId.toString(),
      "timestamp": timestamp.toIso8601String(), 
    }),
  );
  if (response.statusCode == 200) {
    print('Message saved successfully');
  } else {
    print('Failed to save message');
  }
}

}

class ChatMessage {
  final String content;
  final String username;
  final DateTime timestamp; // Adăugăm timestamp-ul

  ChatMessage({required this.content, required this.username, required this.timestamp});
}
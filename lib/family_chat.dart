import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FamilyChatPage extends StatefulWidget {
  final String id; // Receiver's ID
  final String name; // Receiver's name

  const FamilyChatPage({Key? key, required this.id, required this.name}) : super(key: key);

  @override
  FamilyChatPageState createState() => FamilyChatPageState();
}

class FamilyChatPageState extends State<FamilyChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  final ImagePicker _picker = ImagePicker();

  late final String baseUrl;
  late final Uri apiUrl;
  String? _senderId; // To store the logged-in user's ID

  @override
  void initState() {
    super.initState();
    _initializeChat(); // Combine loading sender ID and fetching messages

  _verifyMsgId(); // Check if 'msg_id' is correctly stored
  }

  Future<void> _verifyMsgId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final msgId = prefs.getString('msg_id');
    print('Retrieved msg_id from SharedPreferences: $msgId');
  }

  Future<void> _initializeChat() async {
    await _loadSenderId(); // Wait for the sender ID to load
    if (_senderId != null) {
      await _fetchMessages(); // Only fetch messages if the sender ID is loaded
    } else {
      print('Sender ID is not loaded yet');
    }
  }

  Future<void> _loadSenderId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _senderId = prefs.getString('msg_id'); // Retrieve the logged-in user's ID
    });
  }

  Future<void> _fetchMessages() async {
    if (_senderId == null) {
      print('Sender ID is not loaded yet.');
      return;
    }

    try {
      // Construct URL with query parameters
      final url = Uri.parse('https://lifeec-mobile.onrender.com/api/messages/between-users?senderId=$_senderId&receiverId=${widget.id}');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        setState(() {
          _messages.clear();
          _messages.addAll(jsonResponse.map((msg) {
            return Message(
              content: msg['text'],
              isAdmin: msg['senderId'] == _senderId,
            );
          }).toList());
        });
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _sendMessage() async {
  if (_messageController.text.isNotEmpty && _senderId != null) {
    try {
      final messageData = {
        'senderId': _senderId, // Logged-in user's ID
        'receiverId': widget.id, // Receiver's ID passed from MessagesPage
        'text': _messageController.text,
        'time': DateTime.now().toIso8601String(),
        'isRead': false, // Initial read status as false
      };

      // Log the message data being sent
      print('Sending message: $messageData');

      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(messageData),
      );

      // Log the server's response
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        // Successfully sent; update UI
        final newMessage = Message(
          content: _messageController.text,
          isAdmin: true,
        );
        setState(() {
          _messages.add(newMessage);
        });
        _messageController.clear(); // Clear input field
        print('Message sent successfully!');
      } else {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      // Log the error
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  } else {
    // Log if senderId is unavailable or message is empty
    print('Sender ID is not available or message is empty');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sender ID is not available')),
    );
  }
}

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      // Handle image upload to the backend here if needed
      setState(() {
        _messages.add(Message(content: 'Image: ${pickedFile.path}', isAdmin: true));
      });
    }
  }

  Future<void> _attachFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = result.files.single;
      setState(() {
        _messages.add(Message(content: 'File: ${file.name}', isAdmin: true));
      });
    }
  }

  void _makeCall() {
    // Add your call functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calling...')),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Info'),
              onTap: () {
                Navigator.pop(context);
                // Add your info functionality here
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Add your settings functionality here
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 100,
            leading: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 8),
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(Icons.person, color: Colors.blueAccent),
                ),
              ],
            ),
            title: Text(
              widget.name,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.call, color: Colors.white),
                onPressed: _makeCall,
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: _showMoreOptions,
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Row(
                  mainAxisAlignment: message.isAdmin
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (!message.isAdmin)
                      const CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        radius: 20,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    if (!message.isAdmin) const SizedBox(width: 10),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message.isAdmin
                            ? Colors.blueAccent
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message.content,
                        style: TextStyle(
                          color: message.isAdmin ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    if (message.isAdmin) const SizedBox(width: 10),
                    if (message.isAdmin)
                      const CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        radius: 20,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.blueAccent),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.blueAccent),
                  onPressed: _attachFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Enter your message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String content;
  final bool isAdmin;

  Message({required this.content, required this.isAdmin});
}

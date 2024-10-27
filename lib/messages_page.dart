import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'family_chat.dart';
import 'nutritionist.dart';

class MessagesPage extends StatefulWidget {
  final String userType; // Add userType property

  const MessagesPage({Key? key, required this.userType}) : super(key: key);

  @override
  MessagesPageState createState() => MessagesPageState();
}

class MessagesPageState extends State<MessagesPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
  try {
    final response = await http.get(Uri.parse('http://192.168.1.10:5000/api/contacts'));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        _contacts = jsonResponse.where((contact) {
          if (widget.userType == 'Family Member') {
            return contact['userType'] == 'Nurse';
          } else if (widget.userType == 'Nurse') {
            return contact['userType'] == 'Family Member' || contact['userType'] == 'Nutritionist';
          } else if (widget.userType == 'Nutritionist') {
            return contact['userType'] == 'Nurse';
          }
          return false;
        }).map((contact) {
          return {
            '_id': contact['_id'],
            'name': contact['name'],
          };
        }).toList();
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load contacts');
    }
  } catch (error) {
    print('Error fetching contacts: $error');
    throw Exception('Failed to load contacts');
  }
}

  Future<void> _addContact(
      String name, String subtitle, IconData icon, Widget page) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/api/contacts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'subtitle': subtitle}),
    );

    if (response.statusCode == 201) {
      final contactData = json.decode(response.body);
      setState(() {
        _contacts.add({
          '_id': contactData['_id'], // Add the new contact ID
          'name': name,
          'subtitle': subtitle,
          'icon': icon,
          'page': page,
        });
      });
    } else {
      throw Exception('Failed to add contact');
    }
  }

  Future<void> _editContact(int index, String name, String subtitle,
      IconData icon, Widget page) async {
    final contactId = _contacts[index]['_id']; // Get contact ID
    final response = await http.put(
      Uri.parse(
          'http://localhost:5000/api/contacts/$contactId'), // Use the correct ID
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'subtitle': subtitle}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _contacts[index] = {
          '_id': contactId, // Maintain contact ID
          'name': name,
          'subtitle': subtitle,
          'icon': icon,
          'page': page,
        };
      });
    } else {
      throw Exception('Failed to edit contact');
    }
  }

  Future<void> _deleteContact(int index) async {
    final contactId = _contacts[index]['_id']; // Get contact ID
    final response = await http.delete(
      Uri.parse('http://localhost:5000/api/contacts/$contactId'),
    );

    if (response.statusCode == 204) {
      // Check for no content on successful delete
      setState(() {
        _contacts.removeAt(index);
      });
    } else {
      throw Exception('Failed to delete contact');
    }
  }

  void _showAddContactDialog({int? index}) {
    if (index != null) {
      _nameController.text = _contacts[index]['name'];
      _subtitleController.text = _contacts[index]['subtitle'];
    } else {
      _nameController.clear();
      _subtitleController.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(index == null ? 'Add New Contact' : 'Edit Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _subtitleController,
                decoration: const InputDecoration(labelText: 'Subtitle'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (index == null) {
                  _addContact(
                    _nameController.text,
                    _subtitleController.text,
                    Icons.person,
                    const FamilyChatPage(),
                  );
                } else {
                  _editContact(
                    index,
                    _nameController.text,
                    _subtitleController.text,
                    Icons.person,
                    const FamilyChatPage(),
                  );
                }
                _nameController.clear();
                _subtitleController.clear();
                Navigator.of(context).pop();
              },
              child: Text(index == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToChat(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
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
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              'Messages',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40.0),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.blueAccent),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: _buildContactList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FloatingActionButton(
                    onPressed: () => _showAddContactDialog(),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _buildContactList() {
    final contacts = _contacts.asMap().entries.map((entry) {
      int index = entry.key;
      var contact = entry.value;
      return _buildContactItem(
        context,
        contact['name'],
        contact['subtitle'],
        contact['icon'],
        contact['page'],
        index,
      );
    }).toList();

    if (_searchQuery.isEmpty) {
      return contacts;
    } else {
      return contacts.where((contact) {
        final contactName =
            (contact as ListTile).title.toString().toLowerCase();
        return contactName.contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  Widget _buildContactItem(BuildContext context, String name, String subtitle,
      IconData icon, Widget page, int index) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blueAccent,
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(name,
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      onTap: () => _navigateToChat(context, page),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blueAccent),
            onPressed: () => _showAddContactDialog(index: index),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _deleteContact(index),
          ),
        ],
      ),
    );
  }
}

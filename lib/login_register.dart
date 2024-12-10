// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'nurse_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'messages_page.dart';

class LoginRegister extends StatefulWidget {
  const LoginRegister({super.key});

  @override
  LoginRegisterState createState() => LoginRegisterState();
}

class LoginRegisterState extends State<LoginRegister>
    with SingleTickerProviderStateMixin {
  bool isSignIn = true;
  bool isLoading = false;
  bool isPasswordVisible = false;

  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  final TextEditingController _signInEmailController = TextEditingController();
  final TextEditingController _signInPasswordController =
      TextEditingController();
  final TextEditingController _signUpNameController = TextEditingController();
  final TextEditingController _signUpEmailController = TextEditingController();
  final TextEditingController _signUpPasswordController =
      TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _buttonAnimation;

  // Load API URL from .env
  final String baseUrl = 'http://localhost:5000/api/auth';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _buttonAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    super.dispose();
  }

  Future<void> handleAuthentication() async {
    if (isSignIn) {
      if (_signInFormKey.currentState!.validate()) {
        setState(() {
          isLoading = true;
        });
        await signIn(
            _signInEmailController.text, _signInPasswordController.text);
        setState(() {
          isLoading = false;
        });
      }
    } else {
      if (_signUpFormKey.currentState!.validate()) {
        setState(() {
          isLoading = true;
        });
        await signUp(_signUpNameController.text, _signUpEmailController.text,
            _signUpPasswordController.text);
        setState(() {
          isLoading = false;
        });
      }
    }
  }

Future<void> signIn(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:5000/api/auth/signin'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

      if (kDebugMode) {
        print('Login successful: $data');
        print('User Type: ${data['userType']}');
        print('Login response data: $data'); // Log the full response
        print('User Name: ${data['name']}');
      }

      // Save user data to SharedPreferences with null checking
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', data['id']); // Save the ObjectId
      await prefs.setString('token', data['token'] ?? ''); // Set a default value if null
      await prefs.setString('userType', data['userType'] ?? '');
      await prefs.setString('email', email);
      await prefs.setString('name', data['name'] ?? '');

      // Check user type and navigate accordingly
      if (data['userType'] == 'Family Member') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MessagesPage(userType: "Family Member"),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NurseDashboardApp()),
        );
      }
    } else {
      if (kDebugMode) {
        print('Login failed: ${response.body}');
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login failed: ${response.body}'),
      ));
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error during login: $error');
    }
  }
}

  // Sign Up API call
  Future<void> signUp(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'), // Backend register route
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('Registration successful: ${data['token']}');
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NurseDashboardApp()),
        );
      } else {
        if (kDebugMode) {
          print('Registration failed: ${response.body}');
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Registration failed: ${response.body}'),
        ));
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error during registration: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 100),
              FadeTransition(
                opacity: _buttonAnimation,
                child: Text(
                  'LIFEEC',
                  style: GoogleFonts.playfairDisplay(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: ToggleButtons(
                  borderColor: Colors.white,
                  fillColor: Colors.white,
                  borderWidth: 2,
                  selectedBorderColor: Colors.white,
                  selectedColor: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(30),
                  onPressed: (int index) {
                    setState(() {
                      isSignIn = index == 1;
                    });
                  },
                  isSelected: [!isSignIn, isSignIn],
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: isSignIn ? Colors.white : Colors.blueAccent,
                          fontSize: 18,
                          fontWeight:
                              isSignIn ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: isSignIn ? Colors.blueAccent : Colors.white,
                          fontSize: 18,
                          fontWeight:
                              isSignIn ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: ListView(
                      children: [
                        const SizedBox(height: 20),
                        isSignIn ? buildSignInForm() : buildSignUpForm(),
                        const SizedBox(height: 20),
                        FadeTransition(
                          opacity: _buttonAnimation,
                          child: GestureDetector(
                            onTap: () => handleAuthentication(),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.blueAccent,
                                    Colors.lightBlueAccent
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        isSignIn ? 'Sign In' : 'Sign Up',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (isSignIn)
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Forgot Password?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Form buildSignInForm() {
    return Form(
      key: _signInFormKey,
      child: Column(
        children: [
          buildEmailField(_signInEmailController),
          const SizedBox(height: 15),
          buildPasswordField(_signInPasswordController),
        ],
      ),
    );
  }

  Form buildSignUpForm() {
    return Form(
      key: _signUpFormKey,
      child: Column(
        children: [
          buildTextField('Name', _signUpNameController, false),
          const SizedBox(height: 15),
          buildEmailField(_signUpEmailController),
          const SizedBox(height: 15),
          buildPasswordField(_signUpPasswordController),
        ],
      ),
    );
  }

  TextFormField buildEmailField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        return null;
      },
    );
  }

  TextFormField buildPasswordField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon:
              Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        ),
      ),
      obscureText: !isPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  TextFormField buildTextField(
      String label, TextEditingController controller, bool obscureText) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.person),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }
}

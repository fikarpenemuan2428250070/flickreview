import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  final bool fromRegister;

  const SignInScreen({super.key, this.fromRegister = false});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorText = '';
  bool _isSignedIn = false; 
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.fromRegister) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration successful! Please log in."),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _signIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final enteredUsername = _usernameController.text.trim();
    final enteredPassword = _passwordController.text.trim();

    if (enteredUsername.isEmpty || enteredPassword.isEmpty) {
      setState(() => _errorText = 'Username and Password are required fields');
      return;
    }

    List<String> userList = prefs.getStringList("users") ?? [];

    if (userList.isEmpty) {
      setState(() => _errorText = 'User is not registered yet.');
      return;
    }

    for (var u in userList) {
      final userData = jsonDecode(u);

      if (userData['username'] == enteredUsername &&
          userData['password'] == enteredPassword) {
        prefs.setString("currentUser", jsonEncode(userData));
        prefs.setBool("_isSignedIn", true);
        prefs.setString("_username", enteredUsername);

        setState(() {
          _errorText = '';
          _isSignedIn = true;
        });

        Navigator.pushReplacementNamed(context, '/');
        return;
      }
    }

    setState(() => _errorText = 'Incorrect username or password.');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // USERNAME
                  TextFormField(
                    controller: _usernameController,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PASSWORD
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      errorText: _errorText.isNotEmpty ? _errorText : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // BUTTON SIGN IN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _signIn,
                      child: const Text('Sign In'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // LINK DAFTAR
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark
                            ? Colors.white
                            : Colors.deepPurple,
                      ),
                      children: [
                        const TextSpan(text: 'Don\'t have an account yet? '),
                        TextSpan(
                          text: 'Register here',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/signup');
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

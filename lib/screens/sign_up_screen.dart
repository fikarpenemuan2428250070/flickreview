import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _errorText = '';
  bool _obsecurePassword = true;

  void _signUp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String name = _nameController.text.trim();
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    // Validasi konfirmasi password
    if (password != confirmPassword) {
      setState(() {
        _errorText = 'Konfirmasi password tidak sama.';
      });
      return;
    }

    // Validasi kompleksitas password
    if (password.length < 8 ||
        !password.contains(RegExp(r'[A-Z]')) ||
        !password.contains(RegExp(r'[a-z]')) ||
        !password.contains(RegExp(r'[0-9]')) ||
        !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      setState(() {
        _errorText =
            'Minimal 8 karakter, kombinasi A-Z, a-z, angka, dan simbol.';
      });
      return;
    }

    setState(() => _errorText = '');

    List<String> userList = prefs.getStringList("users") ?? [];

    // Cek username sudah digunakan
    for (var u in userList) {
      final data = jsonDecode(u);
      if (data['username'] == username) {
        setState(() => _errorText = "Username sudah digunakan.");
        return;
      }
    }

    final newUser = jsonEncode({
      "name": name,
      "username": username,
      "password": password,
    });

    userList.add(newUser);
    await prefs.setStringList("users", userList);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const SignInScreen(fromRegister: true),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: _obsecurePassword,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: _errorText.isNotEmpty ? _errorText : null,
        suffixIcon: IconButton(
          icon: Icon(
            _obsecurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obsecurePassword = !_obsecurePassword;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Pengguna',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password
                  _passwordField(
                    controller: _passwordController,
                    label: 'Kata Sandi',
                  ),
                  const SizedBox(height: 20),

                  // Konfirmasi Password
                  _passwordField(
                    controller: _confirmPasswordController,
                    label: 'Konfirmasi Kata Sandi',
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _signUp,
                    child: const Text('Sign Up'),
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

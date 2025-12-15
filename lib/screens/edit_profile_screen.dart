import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  String oldUsername = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('currentUser');

    if (currentUser != null) {
      final user = jsonDecode(currentUser);

      _nameController.text = user['name'] ?? '';
      _usernameController.text = user['username'] ?? '';
      _bioController.text = user['bio'] ?? '';

      oldUsername = user['username'];
    }
  }

  Future<void> _saveProfile() async {
  final prefs = await SharedPreferences.getInstance();

  final newName = _nameController.text.trim();
  final newUsername = _usernameController.text.trim();
  final newBio = _bioController.text.trim();

  if (newName.isEmpty || newUsername.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nama & Username wajib diisi')),
    );
    return;
  }

  final users = prefs.getStringList('users') ?? [];

  // 🔒 VALIDASI USERNAME (TIDAK BOLEH DUPLIKAT)
  for (final u in users) {
    final user = jsonDecode(u);

    if (user['username'] == newUsername &&
        user['username'] != oldUsername) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username sudah digunakan oleh user lain'),
        ),
      );
      return;
    }
  }

  // ✅ UPDATE currentUser
  final currentUserStr = prefs.getString('currentUser');
  if (currentUserStr != null) {
    final user = jsonDecode(currentUserStr);
    user['name'] = newName;
    user['username'] = newUsername;
    user['bio'] = newBio;

    await prefs.setString('currentUser', jsonEncode(user));
  }

  // ✅ UPDATE users list
  for (int i = 0; i < users.length; i++) {
    final u = jsonDecode(users[i]);
    if (u['username'] == oldUsername) {
      u['name'] = newName;
      u['username'] = newUsername;
      u['bio'] = newBio;
      users[i] = jsonEncode(u);
      break;
    }
  }
  await prefs.setStringList('users', users);

  // ✅ UPDATE username global
  await prefs.setString('_username', newUsername);

  Navigator.pop(context, true);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}

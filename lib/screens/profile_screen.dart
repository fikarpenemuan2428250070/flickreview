import 'dart:convert';
import 'dart:io';

import 'package:flickreview/widgets/profile_info_item.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isSignedIn = false;
  String fullName = '';
  String userName = '';
  int favoritemovieCount = 0;
  String? profileImagePath; // path gambar (disimpan di SharedPreferences)

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Ambil data user + jumlah favorit user sesuai akun
  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool signedIn = prefs.getBool('_isSignedIn') ?? false;

    setState(() {
      isSignedIn = signedIn;
    });

    if (!signedIn) {
      return;
    }

    // Ambil data user dari currentUser
    final String? jsonUser = prefs.getString("currentUser");
    if (jsonUser != null) {
      final Map<String, dynamic> user = jsonDecode(jsonUser);

      setState(() {
        fullName = user["name"] ?? '';
        userName = user["username"] ?? '';
      });
    }

    if (userName.isNotEmpty) {
      // FAVORIT PER USER
      final List<String> favList =
          prefs.getStringList("favorites_$userName") ?? [];

      setState(() {
        favoritemovieCount = favList.length;
      });

      // Load profile image path (jika ada)
      final String? imgPath = prefs.getString('profile_image_$userName');
      setState(() {
        profileImagePath = imgPath;
      });
    }
  }

  // SIGN IN
  void signIn() {
    Navigator.pushNamed(context, '/signin').then((_) {
      _loadUserData(); // refresh otomatis setelah signin
    });
  }

  // SIGN OUT
  Future<void> signOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('_isSignedIn', false);
    await prefs.remove("currentUser");
    // jangan lupa hapus username saved jika ada
    await prefs.remove("_username");

    setState(() {
      isSignedIn = false;
      fullName = '';
      userName = '';
      favoritemovieCount = 0;
      profileImagePath = null;
    });
  }

  // EDIT NAMA (menggunakan dialog input)
  Future<void> _editName() async {
    if (!isSignedIn) return;

    final TextEditingController _controller = TextEditingController(
      text: fullName,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Nama Lengkap'),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Masukkan nama lengkap'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = _controller.text.trim();
              if (newName.isEmpty) {
                // jangan terima nama kosong
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama tidak boleh kosong')),
                );
                return;
              }
              Navigator.pop(context, newName);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _saveName(result);
      setState(() {
        fullName = result;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama berhasil diperbarui')));
    }
  }

  // Simpan nama ke currentUser dan juga update daftar users
  Future<void> _saveName(String newName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Update currentUser
    final currentUserStr = prefs.getString('currentUser');
    if (currentUserStr != null) {
      final Map<String, dynamic> user = jsonDecode(currentUserStr);
      user['name'] = newName;
      prefs.setString('currentUser', jsonEncode(user));
    }

    // Update di users list (jika ada)
    final List<String> users = prefs.getStringList('users') ?? [];
    for (int i = 0; i < users.length; i++) {
      try {
        final Map<String, dynamic> u = jsonDecode(users[i]);
        if (u['username'] == userName) {
          u['name'] = newName;
          users[i] = jsonEncode(u);
          break;
        }
      } catch (_) {
        // skip malformed
      }
    }
    await prefs.setStringList('users', users);
  }

  // PICK PROFILE IMAGE (camera atau gallery)
  Future<void> _pickProfileImage(ImageSource source) async {
    if (!isSignedIn) return;

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked == null) return;

      final String path = picked.path;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // simpan path per user agar persisten
      await prefs.setString('profile_image_$userName', path);

      setState(() {
        profileImagePath = path;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Foto profil disimpan')));
    } catch (e) {
      debugPrint('Error pick image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal mengambil gambar')));
    }
  }

  // Tampilkan opsi pilih camera/galeri
  void _showImageSourceActionSheet() {
    if (!isSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil foto (Kamera)'),
              onTap: () {
                Navigator.pop(context);
                _pickProfileImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickProfileImage(ImageSource.gallery);
              },
            ),
            if (profileImagePath != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Hapus foto profil'),
                onTap: () async {
                  Navigator.pop(context);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('profile_image_$userName');
                  setState(() => profileImagePath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (profileImagePath != null && profileImagePath!.isNotEmpty) {
      final file = File(profileImagePath!);
      if (file.existsSync()) {
        return CircleAvatar(radius: 50, backgroundImage: FileImage(file));
      }
      // jika file path tidak ada lagi, hapus saved path
      // (jangan await di build -> lakukan setState kecil menggunakan microtask)
      Future.microtask(() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('profile_image_$userName');
        setState(() => profileImagePath = null);
      });
    }

    // default placeholder
    return const CircleAvatar(
      radius: 50,
      backgroundImage: AssetImage('images/placeholder_image.png'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Header ungu
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.deepPurple,
          ),

          // Body utama
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // FOTO PROFILE
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 150),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.deepPurple,
                              width: 2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: _buildAvatar(),
                        ),
                        if (isSignedIn)
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.deepPurple,
                            child: IconButton(
                              onPressed: _showImageSourceActionSheet,
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Divider(color: Colors.deepPurple[100]),
                const SizedBox(height: 4),

                // USERNAME
                ProfileInfoItem(
                  icon: Icons.lock,
                  label: 'Pengguna',
                  value: userName,
                  iconColor: Colors.amber,
                ),

                const SizedBox(height: 4),
                Divider(color: Colors.deepPurple[100]),
                const SizedBox(height: 4),

                // NAMA LENGKAP
                ProfileInfoItem(
                  icon: Icons.person,
                  label: 'Nama',
                  value: fullName,
                  showEditIcon: isSignedIn,
                  onEditPressed: () {
                    _editName();
                  },
                  iconColor: Colors.blue,
                ),

                const SizedBox(height: 4),
                Divider(color: Colors.deepPurple[100]),
                const SizedBox(height: 4),

                // FAVORIT PER USER
                ProfileInfoItem(
                  icon: Icons.favorite,
                  label: 'Favorit',
                  value: favoritemovieCount > 0
                      ? '$favoritemovieCount Items'
                      : 'Tidak ada',
                  iconColor: Colors.red,
                ),

                const SizedBox(height: 4),
                Divider(color: Colors.deepPurple[100]),
                const SizedBox(height: 20),

                // BUTTON SIGN IN / SIGN OUT
                isSignedIn
                    ? TextButton(
                        onPressed: signOut,
                        child: const Text('Sign Out'),
                      )
                    : TextButton(
                        onPressed: signIn,
                        child: const Text('Sign In'),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

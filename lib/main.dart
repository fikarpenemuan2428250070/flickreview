import 'package:flickreview/screens/change_password_screen.dart';
import 'package:flickreview/screens/edit_profile_screen.dart';
import 'package:flickreview/screens/favorite_screen.dart';
import 'package:flickreview/screens/home_screen.dart';
import 'package:flickreview/screens/profile_screen.dart';
import 'package:flickreview/screens/setting_screen.dart';
import 'package:flickreview/screens/sign_in_screen.dart';
import 'package:flickreview/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_controller.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlickReview',

      // 🌞 LIGHT MODE
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,

        scaffoldBackgroundColor: Colors.white,

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple,
          iconTheme: IconThemeData(color: Colors.deepPurple),
          titleTextStyle: TextStyle(
            color: Colors.deepPurple,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(color: Colors.deepPurple),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.deepPurple,
          elevation: 0,
          showUnselectedLabels: true,
        ),
      ),

      // 🌙 DARK MODE (yang sudah kamu buat)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,

        scaffoldBackgroundColor: const Color(0xFF1F1B2E),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B5CF6),
          background: Color(0xFF1F1B2E),
          surface: Color(0xFF8B5CF6),
          onPrimary: Colors.white,
          onSurface: Colors.white,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),

        // 🔥 INI YANG WAJIB ADA
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF8B5CF6),
            foregroundColor: Colors.white, // ⬅️ TEXT SIGN IN PUTIH
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF1F1B2E)),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF8B5CF6),
          selectedItemColor: Color(0xFF1F1B2E),
          unselectedItemColor: Colors.white,
          showUnselectedLabels: true,
        ),

        cardTheme: const CardThemeData(color: Color(0xFF8B5CF6)),

        dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1F1B2E)),
      ),

      // 🔁 CONNECT KE THEME CONTROLLER
      themeMode: context.watch<ThemeController>().themeMode,

      // 🏠 HALAMAN UTAMA
      home: const MainScreen(),

      // 🚦 SEMUA ROUTE WAJIB TERDAFTAR DI SINI
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/setting': (context) => const SettingScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    FavoriteScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favorite',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            showUnselectedLabels: true,
          ),
        ),
      ),
    );
  }
}

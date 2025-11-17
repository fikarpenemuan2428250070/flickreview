import 'package:flickreview/data/movies_data.dart';
import 'package:flickreview/screens/detail_screnn.dart';
import 'package:flickreview/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlickReview',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.deepPurple),
          titleTextStyle: TextStyle(
            color: Colors.deepPurple,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ).copyWith(primary: Colors.deepPurple, surface: Colors.deepPurple[50]),
        useMaterial3: true,
      ),
      home: DetailScreen(movie: movieList[0]),
    );
  }
}

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   //TODO: 1. Deklarasi variabel
//   int _currentIndex = 0;
//   final List<Widget> _children = [
//     HomeScreen(),
//     SearchScreen(),
//     FavoriteScreen(),
//     ProfileScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       //TODO: 2. Buat properti body berupa widget yang ditampilkan
//       body: _children[_currentIndex],

//       //TODO: 3. Buat properti bottomNavigationBar dengan nilai Theme
//       bottomNavigationBar: Theme(
//         //TODO: 4. Buat data dan child dari Theme
//         data: Theme.of(context).copyWith(canvasColor: Colors.deepPurple[50]),
//         child: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           onTap: (index) {
//             setState(() {
//               _currentIndex = index;
//             });
//           },
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home, color: Colors.deepPurple),
//               label: 'Home',
//             ),

//             BottomNavigationBarItem(
//               icon: Icon(Icons.search, color: Colors.deepPurple),
//               label: 'Search',
//             ),

//             BottomNavigationBarItem(
//               icon: Icon(Icons.favorite, color: Colors.deepPurple),
//               label: 'favorite',
//             ),

//             BottomNavigationBarItem(
//               icon: Icon(Icons.person, color: Colors.deepPurple),
//               label: 'Profile',
//             ),
//           ],
//           selectedItemColor: Colors.deepPurple,
//           unselectedItemColor:Colors.deepPurple[100],
//           showUnselectedLabels: true,
//         ),
//       ),
//     );
//   }
// }

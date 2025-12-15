import 'package:flickreview/data/movies_data.dart';
import 'package:flickreview/models/movies.dart';
import 'package:flickreview/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flickreview/screens/search_screen.dart';
import 'package:flickreview/screens/setting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -----------------------------------------
      // 🔥 SIDEBAR (DRAWER)
      // -----------------------------------------
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Setting'),
              onTap: () {
                Navigator.pop(context); // tutup drawer dulu
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                showAboutDialog(
                  context: context,
                  applicationName: "FlickReview",
                  applicationVersion: "1.0.0",
                  applicationLegalese: "© 2025 FlickReview App",
                );
              },
            ),
          ],
        ),
      ),

      // -----------------------------------------
      // 🔥 APP BAR
      // -----------------------------------------
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Buka sidebar
              },
            );
          },
        ),
        title: const Text('FlickReview'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SearchScreen()),
              );
            },
          ),
        ],
      ),

      // -----------------------------------------
      // 🔥 GRID MOVIE
      // -----------------------------------------
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.55,
        ),
        padding: const EdgeInsets.all(8),
        itemCount: movieList.length,
        itemBuilder: (context, index) {
          Movie movie = movieList[index];
          return ItemCard(movie: movie);
        },
      ),
    );
  }
}

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flickreview/models/movies.dart';
import 'package:flickreview/screens/gallery_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'review_screen.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;
  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Widget _buildTrailer(BuildContext context) {
    final trailerUrl =
        "https://www.youtube.com/watch?v=${widget.movie.trailerId}"; // Avengers

    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(trailerUrl);

        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tidak dapat membuka trailer")),
          );
        }
      },

      child: Stack(
        alignment: Alignment.center,
        children: [
          CachedNetworkImage(
            imageUrl: widget.movie.posterUrl, // sementara pakai poster biasa
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          ),

          Container(
            width: double.infinity,
            height: 220,
            color: Colors.black.withOpacity(0.3),
          ),

          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }

  bool isFavorite = false;
  bool isSignedIn = false;

  String favoritesKey = "";

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
    _loadFavoriteStatus();
  }

  Future<void> _checkSignInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isSignedIn = prefs.getBool('_isSignedIn') ?? false;
    });
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonUser = prefs.getString("currentUser");
    if (jsonUser == null) return;

    final user = jsonDecode(jsonUser);
    final username = user["username"];

    favoritesKey = "favorites_$username";

    List<String> favorites = prefs.getStringList(favoritesKey) ?? [];

    setState(() {
      isFavorite = favorites.contains(widget.movie.title);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();

    if (!isSignedIn) {
      Navigator.pushNamed(context, '/signin');
      return;
    }

    final jsonUser = prefs.getString("currentUser");
    if (jsonUser == null) return;

    final user = jsonDecode(jsonUser);
    final username = user["username"];

    favoritesKey = "favorites_$username";

    List<String> favorites = prefs.getStringList(favoritesKey) ?? [];

    setState(() {
      isFavorite = !isFavorite;
    });

    if (isFavorite) {
      if (!favorites.contains(widget.movie.title)) {
        favorites.add(widget.movie.title);
      }
    } else {
      favorites.remove(widget.movie.title);
    }

    prefs.setStringList(favoritesKey, favorites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= TRAILER + BACK BUTTON =================
            Stack(
              children: [
                _buildTrailer(context),

                Positioned(
                  top: 40,
                  left: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),

            // ================= CONTENT =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // POSTER + TITLE
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: widget.movie.posterUrl,
                          width: 120,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${widget.movie.title} (${widget.movie.year})",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  onPressed: _toggleFavorite,
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // DIRECTOR
                            RichText(
                              text: TextSpan(
                                text: "Director: ",
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  TextSpan(
                                    text: widget.movie.director,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Divider(color: Colors.deepPurple.shade100),
                  const SizedBox(height: 20),

                  // Duration
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text("Duration: ${widget.movie.duration}"),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Release
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.green),
                      const SizedBox(width: 8),
                      Text("Release: ${widget.movie.releaseDate}"),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Language
                  Row(
                    children: [
                      const Icon(Icons.language, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text("Language: ${widget.movie.language}"),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Divider(color: Colors.deepPurple.shade100),
                  const SizedBox(height: 20),

                  // CAST
                  const Text(
                    'Cast',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    widget.movie.cast.join(", "),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),
                  Divider(color: Colors.deepPurple.shade100),
                  const SizedBox(height: 20),

                  // SINOPSIS
                  const Text(
                    'Synopsis',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(widget.movie.synopsis),

                  const SizedBox(height: 20),
                  Divider(color: Colors.deepPurple.shade100),
                  const SizedBox(height: 20),

                  // GALERI
                  const Text(
                    'Galery',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.movie.imageUrls.length,
                      itemBuilder: (context, index) {
                        final imageUrl = widget.movie.imageUrls[index];
                        final heroTag = "gallery-${widget.movie.title}-$index";

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GalleryPreviewScreen(
                                  images: widget.movie.imageUrls,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },

                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Hero(
                              tag: heroTag,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: 120,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 4),
                  const Text(
                    'Tap untuk memperbesar',
                    style: TextStyle(fontSize: 11),
                  ),

                  const SizedBox(height: 20),
                  Divider(color: Colors.deepPurple.shade100),
                  const SizedBox(height: 20),

                  // ================== RATING ==================
                  const Text(
                    "Rating",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("IMDb: ${widget.movie.imdbRating}/10"),
                      Text("Rotten Tomatoes: ${widget.movie.rottenTomatoes}%"),
                      Text("FlickReview: ${widget.movie.flickReviewRating}/5"),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Divider(color: Colors.deepPurple.shade100),
                  const SizedBox(height: 20),

                  // REVIEW SECTION
                  const Text(
                    "FlickReview",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.movie.reviews.length,
                      itemBuilder: (context, index) {
                        final review = widget.movie.reviews[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReviewScreen(review: review),
                              ),
                            );
                          },
                          child: Container(
                            width: 260,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: review.profileImage,
                                    width: 55,
                                    height: 55,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        review.reviewerName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.orange,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text("${review.rating}/5"),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        review.shortReview,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),
                  const SizedBox(height: 20),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

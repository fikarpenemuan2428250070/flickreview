import 'package:flickreview/data/movies_data.dart';
import 'package:flickreview/models/movies.dart';
import 'package:flickreview/screens/detail_screnn.dart';
import 'package:flickreview/utils/slide_route.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Movie> _filteredmovies = movieList;
  final TextEditingController _searchController = TextEditingController();

  void _searchmovie(String query) {
    setState(() {
      _filteredmovies = movieList
          .where(
            (c) =>
                c.title.toLowerCase().contains(query.toLowerCase()) ||
                c.year.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movie Search'), centerTitle: true),
      body: Column(
        children: [
          // TEXTFIELD SEARCH
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchmovie, 
              decoration: InputDecoration(
                hintText: 'Search Movies ...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          _searchmovie('');
                          setState(
                            () {},
                          ); 
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
          ),

          // LIST RESULT
          Expanded(
            child: _filteredmovies.isEmpty
                ? const Center(
                    child: Text(
                      'No movie data matches the keyword.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredmovies.length,
                    itemBuilder: (context, index) {
                      final movie = _filteredmovies[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            SlidePageRoute(page: DetailScreen(movie: movie)),
                          );
                        },

                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // POSTER (portrait)
                              Hero(
                                tag: movie
                                    .posterUrl, 
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  width: 90,
                                  height: 130, 
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      movie.posterUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      // loading indicator
                                      loadingBuilder:
                                          (context, child, progress) {
                                            if (progress == null) return child;
                                            return const Center(
                                              child: SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            );
                                          },

                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.broken_image,
                                                size: 36,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              ),

                              // TEXT INFO
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    12,
                                    12,
                                    12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        movie.year,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),

                                      const SizedBox(height: 6),
                                      Text(
                                        movie.type,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        movie.genre,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

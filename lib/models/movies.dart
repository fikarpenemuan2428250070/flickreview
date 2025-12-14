import 'package:flickreview/models/review.dart';

class Movie {
  final String id;
  final String title;
  final String year;
  final String synopsis;
  final String genre;
  final String director;
  final String duration;
  final String type;
  final String posterUrl;
  final String trailerId;
  final List<String> imageUrls;

  final double imdbRating;
  final int rottenTomatoes;
  final double flickReviewRating;

  final List<String> cast;
  final List<Review> reviews;
  final String releaseDate;
  final String language;

  bool isFavorite;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.synopsis,
    required this.genre,
    required this.director,
    required this.duration,
    required this.type,
    required this.posterUrl,
    required this.trailerId,
    required this.imageUrls,
    required this.imdbRating,
    required this.rottenTomatoes,
    required this.flickReviewRating,
    required this.cast,
    required this.reviews,
    required this.releaseDate,
    required this.language,
    this.isFavorite = false,
  });
}

class Movie {
  final String id;                
  final String title;             
  final String year;              
  final String description;       
  final String genre;             
  final String director;          
  final String duration;          
  final String type;              
  final String imageAsset;        
  final List<String> imageUrls;   

  // Rating
  final double imdbRating;        
  final int rottenTomatoes;       
  final double flickReviewRating; 

  final List<String> cast;
  final String releaseDate;      
  final String language;          

  bool isFavorite;                

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.description,
    required this.genre,
    required this.director,
    required this.duration,
    required this.type,
    required this.imageAsset,
    required this.imageUrls,
    required this.imdbRating,
    required this.rottenTomatoes,
    required this.flickReviewRating,
    required this.cast,
    required this.releaseDate,
    required this.language,
    this.isFavorite = false,
  });
}

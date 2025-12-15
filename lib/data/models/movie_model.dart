import '../../domain/entities/movie_entity.dart';

class MovieModel {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final String? releaseDate;
  final List<String>? genres;
  final int? runtime;
  final String? tagline;
  final double? budget;
  final double? revenue;
  final String? status;
  final List<String>? spokenLanguages;
  final String? backdropPath;

  MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    required this.voteAverage,
    this.releaseDate,
    this.genres,
    this.runtime,
    this.tagline,
    this.budget,
    this.revenue,
    this.status,
    this.spokenLanguages,
    this.backdropPath,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    List<String>? genresList;
    if (json['genres'] != null) {
      genresList = (json['genres'] as List).map<String>((g) => g['name'] as String).toList();
    }

    List<String>? languagesList;
    if (json['spoken_languages'] != null) {
      languagesList = (json['spoken_languages'] as List).map<String>((l) => l['english_name'] as String).toList();
    }

    return MovieModel(
      id: json['id'],
      title: json['title'],
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      voteAverage: (json['vote_average'] as num).toDouble(),
      releaseDate: json['release_date'],
      genres: genresList,
      runtime: json['runtime'],
      tagline: json['tagline'],
      budget: (json['budget'] as num?)?.toDouble(),
      revenue: (json['revenue'] as num?)?.toDouble(),
      status: json['status'],
      spokenLanguages: languagesList,
      backdropPath: json['backdrop_path'],
    );
  }

  String get fullPosterPath {
    if (posterPath == null) return '';
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get fullBackdropPath {
    if (backdropPath == null) return '';
    return 'https://image.tmdb.org/t/p/w1280$backdropPath';
  }

  MovieEntity toEntity() {
    return MovieEntity(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      voteAverage: voteAverage,
      releaseDate: releaseDate,
    );
  }
}
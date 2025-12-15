import 'movie_entity.dart';

class MovieDetailsEntity {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final String? releaseDate;
  final List<String> genres;
  final int runtime;
  final String tagline;
  final double budget;
  final double revenue;
  final String status;
  final List<String> spokenLanguages;
  final String backdropPath;
  final List<VideoEntity> videos;
  final List<CastEntity> cast;
  final List<ReviewEntity> reviews;
  final List<MovieEntity> similarMovies;

  MovieDetailsEntity({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    required this.voteAverage,
    this.releaseDate,
    required this.genres,
    required this.runtime,
    required this.tagline,
    required this.budget,
    required this.revenue,
    required this.status,
    required this.spokenLanguages,
    required this.backdropPath,
    required this.videos,
    required this.cast,
    required this.reviews,
    required this.similarMovies,
  });

  String get fullPosterPath {
    if (posterPath == null) return '';
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get fullBackdropPath {
    if (backdropPath.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w1280$backdropPath';
  }

  String get formattedRuntime {
    if (runtime == 0) return '';
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    if (hours > 0) {
      return '${hours}г ${minutes}хв';
    }
    return '${minutes}хв';
  }

  String get formattedBudget {
    if (budget == 0) return '';
    if (budget >= 1000000000) {
      return '\$${(budget / 1000000000).toStringAsFixed(1)} млрд';
    }
    if (budget >= 1000000) {
      return '\$${(budget / 1000000).toStringAsFixed(1)} млн';
    }
    return '\$${budget.toStringAsFixed(0)}';
  }

  VideoEntity? get mainTrailer {
    try {
      return videos.firstWhere(
            (video) => video.type == 'Trailer' && video.site == 'YouTube',
      );
    } catch (_) {
      try {
        return videos.firstWhere(
              (video) => video.site == 'YouTube',
        );
      } catch (_) {
        return videos.isNotEmpty ? videos.first : null;
      }
    }
  }
}

class VideoEntity {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final bool official;

  const VideoEntity({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    required this.official,
  });

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';
  String get youtubeThumbnail => 'https://img.youtube.com/vi/$key/0.jpg';
}

class CastEntity {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  const CastEntity({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  String get fullProfilePath {
    if (profilePath == null) return '';
    return 'https://image.tmdb.org/t/p/w200$profilePath';
  }
}

class ReviewEntity {
  final String id;
  final String author;
  final String content;
  final String? avatarPath;
  final double rating;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.author,
    required this.content,
    this.avatarPath,
    required this.rating,
    required this.createdAt,
  });

  String get formattedDate {
    return '${createdAt.day}.${createdAt.month}.${createdAt.year}';
  }
}
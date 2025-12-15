import 'package:moviemaster/data/datasources/remote/movie_remote_data_source.dart';
import 'package:moviemaster/data/datasources/movie_local_data_source.dart';
import 'package:moviemaster/domain/entities/movie_entity.dart';
import 'package:moviemaster/domain/entities/movie_details_entity.dart';
import 'package:moviemaster/domain/repositories/movie_repository.dart';

import 'package:moviemaster/data/models/movie_model.dart';
import 'package:moviemaster/data/models/video_model.dart';
import 'package:moviemaster/data/models/credit_model.dart';
import 'package:moviemaster/data/models/review_model.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final MovieLocalDataSource localDataSource;

  MovieRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<MovieEntity>> getPopularMovies({int page = 1}) async {
    try {
      final cachedMovies = await localDataSource.getCachedMovies('popular_$page');
      if (cachedMovies != null) {
        return cachedMovies.map((model) => model.toEntity()).toList();
      }

      final movieModels = await remoteDataSource.getPopularMovies(page: page);

      await localDataSource.cacheMovies(movieModels, 'popular_$page');

      return movieModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      final cachedMovies = await localDataSource.getCachedMovies('popular_$page');
      if (cachedMovies != null) {
        return cachedMovies.map((model) => model.toEntity()).toList();
      }
      throw Exception('Failed to load popular movies: $e');
    }
  }

  @override
  Future<List<MovieEntity>> searchMovies(String query, {int page = 1}) async {
    try {
      final movieModels = await remoteDataSource.searchMovies(query, page: page);
      return movieModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }

  @override
  Future<MovieDetailsEntity> getMovieDetails(int movieId) async {
    try {
      final MovieModel movieDetails = await remoteDataSource.getMovieDetails(movieId);
      final List<VideoModel> videos = await remoteDataSource.getMovieVideos(movieId);
      final List<CreditModel> credits = await remoteDataSource.getMovieCredits(movieId);
      final List<ReviewModel> reviews = await remoteDataSource.getMovieReviews(movieId);
      final List<MovieModel> similarMovies = await remoteDataSource.getSimilarMovies(movieId);

      return MovieDetailsEntity(
        id: movieDetails.id,
        title: movieDetails.title,
        overview: movieDetails.overview,
        posterPath: movieDetails.posterPath,
        voteAverage: movieDetails.voteAverage,
        releaseDate: movieDetails.releaseDate,
        genres: movieDetails.genres ?? [],
        runtime: movieDetails.runtime ?? 0,
        tagline: movieDetails.tagline ?? '',
        budget: movieDetails.budget ?? 0.0,
        revenue: movieDetails.revenue ?? 0.0,
        status: movieDetails.status ?? '',
        spokenLanguages: movieDetails.spokenLanguages ?? [],
        backdropPath: movieDetails.backdropPath ?? '',
        videos: videos.map((video) => VideoEntity(
          id: video.id,
          key: video.key,
          name: video.name,
          site: video.site,
          type: video.type,
          official: video.official,
        )).toList(),
        cast: credits
            .where((credit) => credit.character != null && credit.character!.isNotEmpty)
            .take(20)
            .map((credit) => CastEntity(
          id: credit.id,
          name: credit.name,
          character: credit.character!,
          profilePath: credit.profilePath,
        ))
            .toList(),
        reviews: reviews
            .take(10)
            .map((review) => ReviewEntity(
          id: review.id,
          author: review.author,
          content: review.content,
          avatarPath: review.avatarPath,
          rating: review.rating,
          createdAt: review.createdAt,
        ))
            .toList(),
        similarMovies: similarMovies
            .take(10)
            .map((movie) => MovieEntity(
          id: movie.id,
          title: movie.title,
          overview: movie.overview,
          posterPath: movie.posterPath,
          voteAverage: movie.voteAverage,
          releaseDate: movie.releaseDate,
        ))
            .toList(),
      );
    } catch (e) {
      throw Exception('Failed to load movie details: $e');
    }
  }

  @override
  Future<List<VideoEntity>> getMovieVideos(int movieId) async {
    try {
      final videos = await remoteDataSource.getMovieVideos(movieId);
      return videos.map((video) => VideoEntity(
        id: video.id,
        key: video.key,
        name: video.name,
        site: video.site,
        type: video.type,
        official: video.official,
      )).toList();
    } catch (e) {
      throw Exception('Failed to load videos: $e');
    }
  }

  @override
  Future<List<CastEntity>> getMovieCredits(int movieId) async {
    try {
      final credits = await remoteDataSource.getMovieCredits(movieId);
      return credits
          .where((c) => c.character != null && c.character!.isNotEmpty)
          .map((credit) => CastEntity(
        id: credit.id,
        name: credit.name,
        character: credit.character!,
        profilePath: credit.profilePath,
      ))
          .toList();
    } catch (e) {
      throw Exception('Failed to load credits: $e');
    }
  }

  @override
  Future<List<ReviewEntity>> getMovieReviews(int movieId) async {
    try {
      final reviews = await remoteDataSource.getMovieReviews(movieId);
      return reviews.map((review) => ReviewEntity(
        id: review.id,
        author: review.author,
        content: review.content,
        avatarPath: review.avatarPath,
        rating: review.rating,
        createdAt: review.createdAt,
      )).toList();
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  @override
  Future<List<MovieEntity>> getSimilarMovies(int movieId) async {
    try {
      final similarMovies = await remoteDataSource.getSimilarMovies(movieId);
      return similarMovies.map((movie) => MovieEntity(
        id: movie.id,
        title: movie.title,
        overview: movie.overview,
        posterPath: movie.posterPath,
        voteAverage: movie.voteAverage,
        releaseDate: movie.releaseDate,
      )).toList();
    } catch (e) {
      throw Exception('Failed to load similar movies: $e');
    }
  }
}
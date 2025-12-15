import 'package:mocktail/mocktail.dart';
import 'package:moviemaster/data/datasources/remote/movie_remote_data_source.dart';
import 'package:moviemaster/data/datasources/movie_local_data_source.dart';
import 'package:moviemaster/data/models/movie_model.dart';
import 'package:moviemaster/data/models/video_model.dart';
import 'package:moviemaster/data/models/credit_model.dart';
import 'package:moviemaster/data/models/review_model.dart';

class MockMovieRemoteDataSource extends Mock implements MovieRemoteDataSource {}

class MockMovieLocalDataSource extends Mock implements MovieLocalDataSource {}
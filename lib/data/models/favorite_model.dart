import 'package:hive/hive.dart';

part 'favorite_model.g.dart';

@HiveType(typeId: 0)
class FavoriteModel {
  @HiveField(0)
  final int movieId;

  @HiveField(1)
  final DateTime addedAt;

  FavoriteModel({required this.movieId}) : addedAt = DateTime.now();
}
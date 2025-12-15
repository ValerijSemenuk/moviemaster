import 'dart:convert';

class ReviewModel {
  final String id;
  final String author;
  final String content;
  final String? avatarPath;
  final double rating;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.author,
    required this.content,
    this.avatarPath,
    required this.rating,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String? avatar = json['author_details']['avatar_path'];
    if (avatar != null && avatar.startsWith('/')) {
      avatar = 'https://image.tmdb.org/t/p/w200$avatar';
    }

    return ReviewModel(
      id: json['id'],
      author: json['author'],
      content: json['content'],
      avatarPath: avatar,
      rating: (json['author_details']['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get truncatedContent {
    if (content.length > 200) {
      return '${content.substring(0, 200)}...';
    }
    return content;
  }
}
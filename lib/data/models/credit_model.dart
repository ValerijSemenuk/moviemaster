class CreditModel {
  final int id;
  final String name;
  final String? character;
  final String? profilePath;

  CreditModel({
    required this.id,
    required this.name,
    this.character,
    this.profilePath,
  });

  factory CreditModel.fromJson(Map<String, dynamic> json) {
    return CreditModel(
      id: json['id'],
      name: json['name'],
      character: json['character'],
      profilePath: json['profile_path'],
    );
  }

  String get fullProfilePath {
    if (profilePath == null) return '';
    return 'https://image.tmdb.org/t/p/w200$profilePath';
  }
}
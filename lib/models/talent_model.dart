class TalentModel {
  final String id;
  final String name;
  final String avatar;
  final String background;
  final String talentType;
  final String description;
  final int followers;
  final int likes;
  final List<DynamicModel> dynamics;

  TalentModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.background,
    required this.talentType,
    required this.description,
    required this.followers,
    required this.likes,
    required this.dynamics,
  });

  factory TalentModel.fromJson(Map<String, dynamic> json) {
    return TalentModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      background: json['background'] ?? '',
      talentType: json['talentType'] ?? '',
      description: json['description'] ?? '',
      followers: json['followers'] ?? 0,
      likes: json['likes'] ?? 0,
      dynamics: (json['dynamics'] as List<dynamic>?)
              ?.map((e) => DynamicModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DynamicModel {
  final String id;
  final String content;
  final int likes;
  final String video;
  final String videoCover;

  DynamicModel({
    required this.id,
    required this.content,
    required this.likes,
    required this.video,
    required this.videoCover,
  });

  factory DynamicModel.fromJson(Map<String, dynamic> json) {
    return DynamicModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      likes: json['likes'] ?? 0,
      video: json['video'] ?? '',
      videoCover: json['videoCover'] ?? '',
    );
  }
}


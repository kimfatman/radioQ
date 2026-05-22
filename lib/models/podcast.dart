import 'package:hive/hive.dart';

part 'podcast.g.dart';

@HiveType(typeId: 0)
class Podcast extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String wikiUrl;

  @HiveField(4)
  final String? coverImage;

  @HiveField(5)
  final String? audioUrl;

  @HiveField(6)
  final int duration;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  bool isFavorite;

  @HiveField(9)
  int playCount;

  @HiveField(10)
  List<Chapter> chapters;

  Podcast({
    required this.id,
    required this.title,
    required this.description,
    required this.wikiUrl,
    this.coverImage,
    this.audioUrl,
    this.duration = 0,
    required this.createdAt,
    this.isFavorite = false,
    this.playCount = 0,
    this.chapters = const [],
  });

  String get durationText {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Podcast copyWith({
    String? id,
    String? title,
    String? description,
    String? wikiUrl,
    String? coverImage,
    String? audioUrl,
    int? duration,
    DateTime? createdAt,
    bool? isFavorite,
    int? playCount,
    List<Chapter>? chapters,
  }) {
    return Podcast(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      wikiUrl: wikiUrl ?? this.wikiUrl,
      coverImage: coverImage ?? this.coverImage,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      chapters: chapters ?? this.chapters,
    );
  }
}

@HiveType(typeId: 1)
class Chapter extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final int startTime;

  @HiveField(3)
  final int duration;

  Chapter({
    required this.id,
    required this.title,
    required this.startTime,
    required this.duration,
  });

  String get startTimeText {
    final minutes = startTime ~/ 60;
    final seconds = startTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

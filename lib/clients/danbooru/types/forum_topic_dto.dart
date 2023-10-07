// Project imports:
import 'creator_dto.dart';
import 'forum_post_dto.dart';

class ForumTopicDto {
  final int? id;
  final CreatorDto? creator;
  final CreatorDto? updater;
  final String? title;
  final int? responseCount;
  final bool? isSticky;
  final bool? isLocked;
  final String? createdAt;
  final String? updatedAt;
  final bool? isDeleted;
  final int? categoryId;
  final int? minLevel;

  final ForumPostDto? originalPost;

  ForumTopicDto({
    this.id,
    this.creator,
    this.updater,
    this.title,
    this.responseCount,
    this.isSticky,
    this.isLocked,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
    this.categoryId,
    this.minLevel,
    this.originalPost,
  });

  factory ForumTopicDto.fromJson(Map<String, dynamic> json) {
    return ForumTopicDto(
      id: json['id'],
      creator:
          json['creator'] != null ? CreatorDto.fromJson(json['creator']) : null,
      updater:
          json['updater'] != null ? CreatorDto.fromJson(json['updater']) : null,
      title: json['title'],
      responseCount: json['response_count'],
      isSticky: json['is_sticky'],
      isLocked: json['is_locked'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isDeleted: json['is_deleted'],
      categoryId: json['category_id'],
      minLevel: json['min_level'],
      originalPost: json['original_post'] != null
          ? ForumPostDto.fromJson(json['original_post'])
          : null,
    );
  }

  @override
  String toString() => title ?? '';
}
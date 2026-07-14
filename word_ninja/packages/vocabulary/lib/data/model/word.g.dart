// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WordImpl _$$WordImplFromJson(Map<String, dynamic> json) => _$WordImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      phonetic: json['phonetic'] as String? ?? '',
      example: json['example'] as String? ?? '',
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
      mastery: (json['mastery'] as num?)?.toInt() ?? 0,
      source: json['source'] as String? ?? 'manual',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      nextReviewDate: json['nextReviewDate'] == null
          ? null
          : DateTime.parse(json['nextReviewDate'] as String),
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      focusScore: (json['focusScore'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$WordImplToJson(_$WordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'word': instance.word,
      'meaning': instance.meaning,
      'phonetic': instance.phonetic,
      'example': instance.example,
      'difficulty': instance.difficulty,
      'mastery': instance.mastery,
      'source': instance.source,
      'tags': instance.tags,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'nextReviewDate': instance.nextReviewDate?.toIso8601String(),
      'reviewCount': instance.reviewCount,
      'focusScore': instance.focusScore,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewImpl _$$ReviewImplFromJson(Map<String, dynamic> json) => _$ReviewImpl(
      id: json['id'] as String,
      wordId: json['wordId'] as String,
      reviewTime: DateTime.parse(json['reviewTime'] as String),
      score: (json['score'] as num?)?.toInt() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      interval: (json['interval'] as num?)?.toInt() ?? 0,
      scheduledFor: json['scheduledFor'] == null
          ? null
          : DateTime.parse(json['scheduledFor'] as String),
    );

Map<String, dynamic> _$$ReviewImplToJson(_$ReviewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'wordId': instance.wordId,
      'reviewTime': instance.reviewTime.toIso8601String(),
      'score': instance.score,
      'isCompleted': instance.isCompleted,
      'interval': instance.interval,
      'scheduledFor': instance.scheduledFor?.toIso8601String(),
    };

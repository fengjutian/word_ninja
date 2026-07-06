import 'dart:math' as math;

/// 用户领域实体
class User {
  final String id;
  final String email;
  final String nickname;
  final String? avatar;
  final int level;
  final int exp;

  const User({
    required this.id,
    required this.email,
    required this.nickname,
    this.avatar,
    this.level = 1,
    this.exp = 0,
  });

  /// 升级所需经验
  int get expToNextLevel {
    int total = 0;
    for (int i = 1; i <= level; i++) {
      total += (1500 * math.pow(1.15, i - 1)).round();
    }
    return total;
  }

  /// 当前等级进度
  double get levelProgress {
    final prevExp = () {
      int total = 0;
      for (int i = 1; i < level; i++) {
        total += (1500 * math.pow(1.15, i - 1)).round();
      }
      return total;
    }();
    final needed = expToNextLevel - prevExp;
    final current = exp - prevExp;
    return (current / needed).clamp(0.0, 1.0);
  }

  /// 忍阶名称
  String get rank {
    if (level >= 100) return '英语传奇';
    if (level >= 80) return '影级大师';
    if (level >= 50) return '忍者大师';
    if (level >= 40) return '精英忍者';
    if (level >= 30) return '上忍';
    if (level >= 20) return '中忍';
    if (level >= 10) return '下忍';
    return '学徒龟';
  }

  User copyWith({
    String? id,
    String? email,
    String? nickname,
    String? avatar,
    int? level,
    int? exp,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        nickname: nickname ?? this.nickname,
        avatar: avatar ?? this.avatar,
        level: level ?? this.level,
        exp: exp ?? this.exp,
      );
}

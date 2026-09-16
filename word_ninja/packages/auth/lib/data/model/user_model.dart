/// 用户数据模型
class UserModel {
  final String id;
  final String email;
  final String nickname;
  final String? avatar;
  final int level;
  final int exp;
  final bool isPro;

  const UserModel({
    required this.id,
    required this.email,
    required this.nickname,
    this.avatar,
    this.level = 1,
    this.exp = 0,
    this.isPro = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        nickname: json['nickname'] as String,
        avatar: json['avatar'] as String?,
        level: (json['level'] as num?)?.toInt() ?? 1,
        exp: (json['exp'] as num?)?.toInt() ?? 0,
        isPro: json['isPro'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'nickname': nickname,
        'avatar': avatar,
        'level': level,
        'exp': exp,
        'isPro': isPro,
      };
}

class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? username;
  final String? avatar;
  final String? token;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.username,
    this.avatar,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      username: json['username'],
      avatar: json['avatar'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'username': username,
      'avatar': avatar,
      'token': token,
    };
  }
}

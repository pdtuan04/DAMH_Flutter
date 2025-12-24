class User{
  final String username;
  final String email;

  User({required this.username, required this.email});
  factory User.fromJson(Map<String, dynamic> json) {
    // Lưu ý: API của bạn trả về lồng trong object "result"
    final result = json['result'];
    return User(
      username: result['userName'] ?? '',
      email: result['email'] ?? '',
    );
  }
}
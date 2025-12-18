class LoginRequest{
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson(){
    return {
      'username': username,
      'password': password
    };
  }
}
class LoginResponse {
  final bool status;
  final String message;
  final String token;
  final List<String> roles;

  LoginResponse({
    required this.status,
    required this.message,
    required this.token,
    required this.roles,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
    );
  }
}
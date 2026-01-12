class User {
  final String id;
  final String username;
  final String email;
  final DateTime? createAt;
  final List<String>? roles;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.createAt,
    this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Cho API user-profile
    if (json.containsKey('result')) {
      final result = json['result'];
      return User(
        id: result['id'] ?? '',
        username: result['userName'] ?? '',
        email: result['email'] ?? '',
      );
    }
    
    // Cho API Manager
    return User(
      id: json['id'] ?? '',
      username: json['userName'] ?? '',
      email: json['email'] ?? '',
      createAt: json['createAt'] != null ? DateTime.parse(json['createAt']) : null,
      roles: json['role'] != null ? List<String>.from(json['role']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': username,
      'email': email,
      'createAt': createAt?.toIso8601String(),
      'role': roles,
    };
  }

  String get primaryRole => roles?.isNotEmpty == true ? roles!.first : 'User';
}

class UserPagedResponse {
  final int totalCount;
  final List<User> users;

  UserPagedResponse({
    required this.totalCount,
    required this.users,
  });

  factory UserPagedResponse.fromJson(Map<String, dynamic> json) {
    return UserPagedResponse(
      totalCount: json['recordsTotal'] ?? 0,
      users: (json['data'] as List?)?.map((item) => User.fromJson(item)).toList() ?? [],
    );
  }
}

class Role {
  final String id;
  final String name;

  Role({required this.id, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
class User {
  final String id;
  final String login;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? role;
  final String? contractor;
  final String? avatarUrl;
  final String token;

  const User({
    required this.id,
    required this.login,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.role,
    this.contractor,
    this.avatarUrl,
    required this.token,
  });

  String get name => '$firstName $lastName';
  String get initials =>
      '${firstName.isNotEmpty ? firstName[0].toUpperCase() : ''}'
      '${lastName.isNotEmpty ? lastName[0].toUpperCase() : ''}';

  User copyWith({
    String? id,
    String? login,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? role,
    String? contractor,
    String? avatarUrl,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      login: login ?? this.login,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      contractor: contractor ?? this.contractor,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      token: token ?? this.token,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      login: json['login'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      contractor: json['contractor'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role,
      'contractor': contractor,
      'avatarUrl': avatarUrl,
    };
  }
}

class AppUser {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;

  AppUser({required this.id, required this.name, required this.email, this.avatarUrl});

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        avatarUrl: json['avatar_url'],
      );
}

class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final int hourly_rate;
  final int night_hourly_rate;
  final int additional_hourly_rate;
  final int night_hours;
  

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.hourly_rate,
    required this.night_hourly_rate,
    required this.additional_hourly_rate,
    required this.night_hours
  });


  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      hourly_rate: json['hourly_rate'] as int,
      night_hourly_rate: json['night_hourly_rate'] as int,
      additional_hourly_rate: json['additional_hourly_rate'] as int,
      night_hours: json['night_hours'] as int
    );
  }
}

class UserLogin {
  final int id;
  final String username;
  final String email;
  final String role;
  final double hourly_rate;
  final double night_hourly_rate;
  final double additional_hourly_rate;
  final double night_hours;
  final String csrf_token;
  

  UserLogin({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.hourly_rate,
    required this.night_hourly_rate,
    required this.additional_hourly_rate,
    required this.night_hours,
    required this.csrf_token
  });


  factory UserLogin.fromJson(Map<String, dynamic> json) {
    return UserLogin(
      id: json['user']['id'] as int,
      username: json['user']['username'] as String,
      email: json['user']['email'] as String,
      role: json['user']['role'] as String,
      hourly_rate: json['user']['hourly_rate'] as double,
      night_hourly_rate: json['user']['night_hourly_rate'] as double,
      additional_hourly_rate: json['user']['additional_hourly_rate'] as double,
      night_hours: json['user']['night_hours'] as double,
      csrf_token: json['csrf_token'] as String
    );
  }
}

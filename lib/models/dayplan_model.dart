class DayPlan {
  final String day;
  final String morning;
  final String afternoon;

  DayPlan({required this.day, required this.morning, required this.afternoon});

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      day: json['day']?.toString() ?? '',
      morning: json['morning']?.toString() ?? '',
      afternoon: json['afternoon']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'day': day, 'morning': morning, 'afternoon': afternoon};
  }

  @override
  String toString() => '$day: $morning | $afternoon';
}

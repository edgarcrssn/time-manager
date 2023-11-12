import 'dart:convert';

class DateClock {
  final String time;

  DateClock({
    required this.time
  });

  factory DateClock.fromJson(Map<String, dynamic> parsedJson){
    return new DateClock(
      time: parsedJson['time'] ??  ""
    );
  }

  Map<String,dynamic> toJson(){
    return {
      "time": time
    };
  }

  static Map<String, dynamic> toMap(DateClock dateClock) => {
    'time': dateClock.time
  };

  static String encode(List<DateClock> dateClocks) => json.encode(
    dateClocks.map<Map<String, dynamic>>((dateClock) => DateClock.toMap(dateClock)).toList()
  );

  static List<DateClock> decode(String dateClocks) => 
    (json.decode(dateClocks) as List<dynamic>).map<DateClock>((item) => DateClock.fromJson(item)).toList();
}
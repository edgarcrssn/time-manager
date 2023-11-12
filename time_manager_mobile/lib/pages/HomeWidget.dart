import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_manager_mobile/Models/DateClock.dart';

class HomeWidget extends StatefulWidget {
  final String token;
  final int userId;
  final String role;
  final String cookie;
  const HomeWidget(
      {Key? key,
      required this.token,
      required this.userId,
      required this.role,
      required this.cookie})
      : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  bool? clockIn;
  String timeSinceLastClockIn = '0';

  bool loading = true;
  bool processing = false;

  late Timer timer = Timer(Duration.zero, () => {});

  @override
  void initState() {
    super.initState();
    getLastClock();
  }

  @override
  void dispose() {
    clearInterval();
    super.dispose();
  }

  Future<void> createClockInOffline() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dateClockListString = prefs.getString('dateClockList') ?? "";
    if (dateClockListString != "") {
      var dateClockList = DateClock.decode(dateClockListString);
      if (dateClockList.isNotEmpty) {
        for (DateClock dateClock in dateClockList) {
          try {
            var userIdFromWidget = widget.userId;
            var tokenFromWidget = widget.token;
            var cookieFromWidget = widget.cookie;
            final response = await http.post(
              Uri.parse(
                  'http://34.16.138.220:4000/api/clocks/$userIdFromWidget'),
              headers: {
                'x-csrf-token': tokenFromWidget,
                'Content-Type': 'application/json',
                'Cookie': cookieFromWidget
              },
              body: json.encode({
                'clock': {'time': dateClock.time},
              }),
            );
            final data = json.decode(response.body);
            final lastClock = data['newClock'];
            print("requete faites");
            setState(() {
              clockIn = lastClock['status'];
            });
          } catch (error) {
            print(error);
          }
        }
      }
      prefs.remove('dateClockList');
    }
  }

  void clearInterval() {
    timer.cancel();
  }

  Future<void> getLastClock() async {
    if (processing) return;

    try {
      var tokenFromWidget = widget.token;
      var userIdFromWidget = widget.userId;
      var cookieFromWidget = widget.cookie;
      await createClockInOffline();
      final response = await http.get(
          Uri.parse(
              'http://34.16.138.220:4000/api/clocks/$userIdFromWidget/last'),
          headers: {
            'x-csrf-token': tokenFromWidget,
            'Content-Type': 'application/json',
            'Cookie': cookieFromWidget
          });
      print(json.decode(response.body));
      print(response.headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final lastClock = data['clock'];

        setState(() {
          clockIn = lastClock['status'];
        });

        if (clockIn!) {
          timeSinceLastClockIn = getTimeElapsedSinceDate(lastClock['time']);
          timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
            setState(() {
              timeSinceLastClockIn = getTimeElapsedSinceDate(lastClock['time']);
            });
          });
        } else {
          clearInterval();
          setState(() {
            timeSinceLastClockIn = '0';
          });
        }
      }
    } catch (error) {
      print('Error fetching clock status: $error');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> clock() async {
    setState(() {
      processing = true;
    });

    try {
      var today = DateTime.now();
      final tempCurrentTime = today.subtract(Duration(hours: 1));
      var currentTime = tempCurrentTime.toString();
      var userIdFromWidget = widget.userId;
      var tokenFromWidget = widget.token;
      var cookieFromWidget = widget.cookie;
      final response = await http.post(
        Uri.parse('http://34.16.138.220:4000/api/clocks/$userIdFromWidget'),
        headers: {
          'x-csrf-token': tokenFromWidget,
          'Content-Type': 'application/json',
          'Cookie': cookieFromWidget
        },
        body: json.encode({
          'clock': {'time': currentTime},
        }),
      );
      final data = json.decode(response.body);
      final lastClock = data['newClock'];

      setState(() {
        clockIn = lastClock['status'];
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have clocked in/out successfully'),
        duration: Duration(seconds: 8),
        backgroundColor: Colors.green,
      ));
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('An error occurred during the clock operation'),
        duration: Duration(seconds: 8),
        backgroundColor: Colors.red,
      ));
      print('Error clocking in/out: $error');
    } finally {
      setState(() {
        processing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Change the background color here
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Click on the button to clock'in/out",
            style: TextStyle(fontSize: 15, color: Colors.purple),
          ),
          if (loading) ...[
            const Text(
              'Loading...',
              style: TextStyle(fontSize: 15, color: Colors.purple),
            ),
          ] else if (processing) ...[
            const Text(
              'Processing...',
              style: TextStyle(fontSize: 15, color: Colors.purple),
            ),
          ] else ...[
            ElevatedButton(
              onPressed: () => clock(),
              child: Text(
                processing
                    ? 'Processing...'
                    : (clockIn ?? false)
                        ? 'Clock Out'
                        : 'Clock In',
              ),
            ),
          ],
        ],
      ),
    );
  }

  String getTimeElapsedSinceDate(String date) {
    DateTime currentDate = DateTime.now();
    DateTime pastDate = DateTime.parse(date);

    Duration difference = currentDate.difference(pastDate);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}

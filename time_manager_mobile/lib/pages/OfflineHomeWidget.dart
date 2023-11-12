import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_manager_mobile/Models/DateClock.dart';

class OfflineHomeWidget extends StatefulWidget {
  bool isConnected = false;
  OfflineHomeWidget({super.key});

  @override
  State<OfflineHomeWidget> createState() => _OfflineHomeWidgetState();
}

class _OfflineHomeWidgetState extends State<OfflineHomeWidget> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<DateClock> dateClockList = List.empty(growable: true);


  void loadListOfDateClock() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dateClockListString = prefs.getString('dateClockList') ?? "";
    if(dateClockListString != ""){
      dateClockList = DateClock.decode(dateClockListString);
    }
  }

  void resetListOfDateClock() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dateClockList = List.empty(growable: true);
    prefs.remove('dateClockList');
  }

  void addDateClock(DateClock dateClock) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dateClockList.add(dateClock);
    final String encodedData = DateClock.encode(dateClockList);
    prefs.setString('dateClockList', encodedData);
    loadListOfDateClock();
    print(dateClockList);
  }

  void onInternetConnected() {
    print('The phone is connected to internet');
  }

  void submitLogin(){
    print('envoie des requêtes');
  }

  void createDateClock(){
    DateTime date = DateTime.now();
    var tempDate = date.subtract(const Duration(hours: 1));
    DateClock dateClock = DateClock(time: tempDate.toString());
    addDateClock(dateClock);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('An error occurred while logging in.'),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
  }

  @override
  void initState() {
    super.initState();
    loadListOfDateClock();

    Connectivity().checkConnectivity().then((result) {
      setState(() {
        if (result != ConnectivityResult.none) {
          widget.isConnected = true;
        } else {
          widget.isConnected = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Offline mode to clock'in/out",
              style: TextStyle(color: Colors.purple, fontSize: 25),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
                onPressed: createDateClock,
                child: const Text("Clock'in/out")), 
          ],
        ));
  }
}

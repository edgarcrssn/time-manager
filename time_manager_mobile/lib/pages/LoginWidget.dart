import 'package:flutter/material.dart';
import 'package:time_manager_mobile/Models/UserLoginModel.dart';
import 'package:time_manager_mobile/pages/FAQWidget.dart';
import 'package:http/http.dart' as http;
import 'package:time_manager_mobile/pages/HomeWidget.dart';
import 'package:time_manager_mobile/pages/OfflineHomeWidget.dart';
import 'dart:convert';
import '../services/RoleManager.dart';
import '../services//TokenManager.dart';
import '../services/UserIdManager.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void submitLogin() async {
    try {
      const String apiUrl = 'http://34.16.138.220:4000/login';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type' : 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text
        }),
      );
      if(response.statusCode == 200){
        final responseData = json.decode(response.body);
        UserLogin user = UserLogin.fromJson(responseData);
        final userId = user.id;
        UserIdManager.saveUserId(userId.toString());
        final userRole = user.role;
        RoleManager.saveUserRole(userRole);
        final token = user.csrf_token;
        TokenManager.saveToken(token);
        final String cookie = response.headers['set-cookie'].toString();
        print(cookie);
        // ignore: use_build_context_synchronously
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeWidget(token: token, userId: userId, role: userRole,cookie: cookie,)));
      }
      else {
        throw Error();
      }
    } catch (error) {
      print(error);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: submitLogin,
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
              ElevatedButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  const FAQWidget()));
              }, child: const Text('Go to the FAQ')),
              ElevatedButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => OfflineHomeWidget()));
              }, child: const Text("Go to offline mode"))
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../Model/expense.dart';
import 'dailyexpenses.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController ipAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // Load saved username, password, and IP address from shared preferences
  void _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    String? savedPassword = prefs.getString('password');
    String? savedIpAddress = prefs.getString('ip_address');

    if (savedUsername != null) {
      usernameController.text = savedUsername;
    }

    if (savedPassword != null) {
      passwordController.text = savedPassword;
    }

    if (savedIpAddress != null) {
      // Set the retrieved IP address in the text field
      ipAddressController.text = savedIpAddress;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset('assets/dailyExpenses.png'),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: ipAddressController,
                decoration: const InputDecoration(
                  labelText: 'Put Your IP Address',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Save entered IP address to shared preferences
                String ipAddress = ipAddressController.text;
                await _saveIpAddress(ipAddress);

                // Save IP address to shared preferences for Expense class
                await Expense.saveApiUrl(ipAddress);

                // Implement Login logic here
                String username = usernameController.text;
                String password = passwordController.text;

                if (username.isNotEmpty && password.isNotEmpty) {
                  // Store username and password in shared preferences
                  _saveCredentials(username, password);

                  // Navigate to the daily expense screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DailyExpensesApp(username: username),
                    ),
                  );
                } else {
                  // Show an error message or handle invalid login
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Login Failed'),
                        content: const Text('Invalid username or password.'),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  // Save username, password, and IP address in shared preferences
  void _saveCredentials(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
    prefs.setString('password', password);
  }

  // Save IP address in shared preferences
  Future<void> _saveIpAddress(String ipAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ip_address', ipAddress);
  }
}
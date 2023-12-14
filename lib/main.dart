import 'package:dailyexpenses/widgets/login.dart';
import 'package:flutter/material.dart';


// void main () => runApp(const MyApp());

void main () {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    const title = 'Daily Expenses';

    return MaterialApp(
      title: title,
      home:Scaffold(
        appBar:AppBar(
          title: const Text(title),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('Groceries - \RM150'),
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Clothing - \RM39.00'),
            ),
            ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text('Dinner - \RM7.00'),
            ),
          ],
        ),
      )
    );
  }
}

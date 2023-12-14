import 'package:dailyexpenses/Controller/request_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dailyexpenses/Model/expense.dart';

import 'login.dart';

// void main() {
//   //runApp(DailyExpensesApp(username: 'Hi Nabil'));
// }

class DailyExpensesApp extends StatelessWidget {
  final String username;

  const DailyExpensesApp({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ExpenseList(username: username),
    );
  }
}

class ExpenseList extends StatefulWidget {
  final String username;

  const ExpenseList({super.key, required this.username});

  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  final List<Expense> expenses = [];
  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController txtDateController = TextEditingController();
  //added new parameter for Expense Constructor - DateTime text
  double totalAmount = 0.0;
  bool showFooter = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _showMessage("Welcome ${widget.username}");

      RequestController req = RequestController(
          path: "/api/timezone/Asia/Kuala_Lumpur",
          server: "http://worldtimeapi.org");
      req.get().then((value) {
        dynamic res = req.result();
        txtDateController.text =
            res["datetime"].toString().substring(0,19).replaceAll('T',' ');
      });

      expenses.addAll(await Expense.loadAll());

      setState(() {
        calculateTotal();
      });
    });
    // Start the timer when the page is loaded
    // startTimer();
  }

  void _addExpense() async {
    String description = descController.text.trim();
    String amount = amountController.text.trim();
    String txtDate = txtDateController.text.trim();

    if (description.isNotEmpty && amount.isNotEmpty) {
      Expense exp =
      Expense(double.parse(amount), description, txtDate);
      if (await exp.save()){
        setState(() {
          expenses.add(exp);
          descController.clear();
          amountController.clear();
          txtDateController.clear();
          calculateTotal();
        });
      }else {
        _showMessage("Failed to save Expenses data");
      }
    }
  }

  void calculateTotal() {
    totalAmount = 0;
    for (Expense ex in expenses){
      totalAmount += ex.amount;
    }
    totalAmountController.text = totalAmount.toString();
  }

  void _removeExpense(int index) {
    totalAmount -= expenses[index].amount;
    setState(() {
      expenses.removeAt(index);
      totalAmountController.text = totalAmount.toString();
    });
  }

  //function to display message at bottom of scaffold
  void _showMessage(String msg) {
    if (mounted){
      // make sure this context is still mounted/exist
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
        ),
      );
    }
  }

  // Navigate to Edit Screen
  void _editExpense(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExpenseScreen(
          expense: expenses[index],
          onSave: (editedExpense){
            setState((){
              totalAmount += editedExpense.amount - expenses[index].amount;
              expenses[index] = editedExpense;
              totalAmountController.text = totalAmount.toString();
            });
          },
        ),
      ),
    );
  }

  //new fn - Date and time picker on textfield
  _selectDate()async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedDate != null && pickedTime != null){
      setState(() {
        txtDateController.text =
        "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}"
            "${pickedTime.hour}:${pickedTime.minute}:00";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Implement your logout logic here
              // For example, you can navigate to the login page
              Navigator.of(context)
                  .pushAndRemoveUntil(
                CupertinoPageRoute(
                    builder: (context) => const LoginScreen()
                ),
                    (_) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (RM)',
              ),
            ),
          ),
          Padding(
            //new textfield for the date and time
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.datetime,
              controller: txtDateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: const InputDecoration(
                labelText: 'Date: ',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: totalAmountController,
              decoration: InputDecoration(
                labelText: 'Total Amount (RM):',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addExpense,
            child: Text('Add Expense'),
          ),
          Container(
            child: _buildListView(),
          ),
          // // The footer with a timer
          // AnimatedOpacity(
          //   opacity: showFooter ? 1.0 : 0.0,
          //     duration: Duration(seconds: 1),
          //     child: Container(
          //     color: Colors.black,
          //     padding: EdgeInsets.all(16.0),
          //     child: Row(
          //           children: [
          //                 Text(
          //                 'Hi ${data}!',
          //                 style: TextStyle(color: Colors.white, fontSize: 16),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // void startTimer() {
  //   const duration = Duration(seconds: 5);
  //
  //   Timer(duration, () {
  //     // Timer callback to hide the footer after the specified duration
  //     setState(() {
  //       showFooter = false;
  //     });
  //   });
  // }

  Widget _buildListView() {
    return Expanded(
      child: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          //Unique key for each item
          return Dismissible(
            key: Key(expenses[index].amount.toString()), //Unique key for each item
            background: Container(
              color: Colors.red,
              child: Center(
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            onDismissed: (direction){
              //Handle item removal here
              _removeExpense(index);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Item dismissed')));
            },
            child: Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(expenses[index].desc),
                subtitle: Row(children: [
                  //edited
                  Text('Amount: RM ${expenses[index].amount}'),
                  const Spacer(),
                  Text('Date: ${expenses[index].dateTime}'),
                ],),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeExpense(index),
                ),
                onLongPress: (){
                  _editExpense(index);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class EditExpenseScreen extends StatelessWidget{
  final Expense expense;
  final Function(Expense) onSave;

  EditExpenseScreen({required this.expense, required this.onSave});

  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController txtDateController = TextEditingController();

  // Widget build method and user interface (UI) goes here
  @override
  Widget build(BuildContext context){
    // Initialize the controllers with the current expense details
    descController.text = expense.desc;
    amountController.text = expense.amount.toString();
    txtDateController.text = expense.dateTime;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expense'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
          ),
          Padding(
            //new textfield for the date and time
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.datetime,
              controller: txtDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Date: ',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount (RM)',
              ),
            ),
          ),
          ElevatedButton(
              onPressed: (){
                // Save the edited details
                onSave(Expense(double.parse(amountController.text)
                    ,descController.text, expense.dateTime));
                // Navigate back to the ExpenseList screen
                Navigator.pop(context);
              },
              child: Text('Save')
          ),
        ],
      ),
    );
  }
}

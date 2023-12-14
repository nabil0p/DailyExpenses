import 'package:shared_preferences/shared_preferences.dart';
import 'package:dailyexpenses/Controller/sqlite_db.dart';
import '../Controller/request_controller.dart';

class Expense {
  static const String SQLiteTable = "expense";
  int? id;
  String desc;
  double amount;
  String dateTime;

  Expense(this.amount, this.desc, this.dateTime);

  Expense.fromJson(Map<String, dynamic> json)
      : desc = json['desc'] as String,
        amount = double.parse(json['amount'] as dynamic),
        dateTime = json['dateTime'] as String,
        id = json['id'] as int?;

  Map<String, dynamic> toJson() =>
      {'desc': desc, 'amount': amount, 'dateTime': dateTime};

  static const String apiUrlKey = "api_url";

  static Future<void> saveApiUrl(String apiUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(apiUrlKey, apiUrl);
  }

  static Future<String?> getApiUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(apiUrlKey);
  }

  Future<bool> save() async {
    String? apiUrl = await getApiUrl();

    await saveApiUrl(apiUrl ?? ""); // Save the URL in case it's not already stored

    await SQLiteDB().insert(SQLiteTable, toJson());

    RequestController req =
    RequestController(path: "/api/expenses.php", server: "http://${apiUrl ?? ''}");
    req.setBody(toJson());
    await req.post();

    if (req.status() == 200) {
      return true;
    } else {
      if (await SQLiteDB().insert(SQLiteTable, toJson()) != 0) {
        return true;
      } else {
        return false;
      }
    }
  }

  static Future<List<Expense>> loadAll() async {
    List<Expense> result = [];

    String? apiUrl = await getApiUrl();

    RequestController req =
    RequestController(path: "/api/expenses.php", server: "http://${apiUrl ?? ''}");
    await req.get();

    if (req.status() == 200 && req.result() != null) {
      for (var item in req.result()) {
        result.add(Expense.fromJson(item));
      }
    } else {
      // Retrieve data from SQLite if API request fails or no data received
      List<Map<String, dynamic>> sqliteData =
      await SQLiteDB().queryAll(SQLiteTable);

      for (var item in sqliteData) {
        result.add(Expense.fromJson(item));
      }
    }

    return result;
  }
}
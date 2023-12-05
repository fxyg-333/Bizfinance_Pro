import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance(); //Under saving goals income and record payment payment
  runApp(MyApp());
  // Main for Budget and expenses
  runApp(MaterialApp(
    initialRoute: '/set_budget',
    routes: {
      '/set_budget': (context) => SetBudgetScreen(),
      '/record_expense': (context) => RecordExpenseScreen(),
    },//End for Budget and expenses
  ));
}
// Start Manage State
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BudgetProvider()),
        ChangeNotifierProvider(create: (context) => ExpenseProvider()),
        ChangeNotifierProvider(create: (context) => SavingsProvider()),
        ChangeNotifierProvider(create: (context) => IncomeProvider()),
        ChangeNotifierProvider(create: (context) => PaymentProvider()),
      ],
      child: MyApp(),
    ),
  );
}
// main.dart file to initialize SharedPreferences


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/set_budget',
      routes: {
        '/set_budget': (context) => SetBudgetScreen(),
        '/record_expense': (context) => RecordExpenseScreen(),
      },
    );
  }
}
 // End Manage State
Future<User?> checkUserLoggedIn() async {
  return FirebaseAuth.instance.authStateChanges().first;
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'BizfinancePro',
      // ... other configuration ...
    );
  }
}
// AuthenticationScreen, RegistrationScreen, and LoginScreen classes

// Logout

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Other content on the home screen

            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  // Logout successful
                } catch (e) {
                  // Handle logout errors
                  print('Error during logout: $e');
                }
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
// Logout

// AuthenticationScreen, RegistrationScreen, and LoginScreen classes
@override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: checkUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Display a loading indicator while checking user state.
        }
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in, navigate to the HomeScreen.
          return const MaterialApp(
            home: HomeScreen(),
          );
        } else {
          // User is not logged in, navigate to the AuthenticationScreen.
          return const MaterialApp(
            home: AuthenticationScreen(),
          );
        }
      },
    );
  } // End AuthenticationScreen, RegistrationScreen, and LoginScreen classes

   // Start of Creating Registration and Login Screens
class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                );
              },
              child: const Text('Register'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}    // Starting of the RegistrationScreen

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _register() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Registration successful
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful')),
      );
    } catch (e) {
      // Handle registration errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Invalid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _register();
                  }
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}      // End of the RegistrationScreen
// Starting of LoginScreen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Login successful
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful')),
      );
    } catch (e) {
      // Handle login errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Invalid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _login();
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}   // End of Creating Registration and Login Screens

//Start Budgeting and Expenses

class SetBudgetScreen extends StatefulWidget {
  @override
  _SetBudgetScreenState createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  double budget = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Budget'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter your budget'),
              onChanged: (value) {
                setState(() {
                  budget = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 20),
            FlatButton(
              onPressed: () {
                // Implement the logic to save the budget value to your data storage.
                // You can use a database or shared preferences for this.
              },
              child: Text('Set Budget'),
              color: Colors.blue,
              textColor: Colors.white,
            ),
            SizedBox(height: 20),
            RaisedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/record_expense');
              },
              child: Text('Record Expenses'),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordExpenseScreen extends StatefulWidget {
  @override
  _RecordExpenseScreenState createState() => _RecordExpenseScreenState();
}

class _RecordExpenseScreenState extends State<RecordExpenseScreen> {
  List<String> expenses = [];
  String newExpense = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Expenses'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Enter your expense'),
            onChanged: (value) {
              setState(() {
                newExpense = value;
              });
            },
          ),
          FlatButton(
            onPressed: () {
              setState(() {
                if (newExpense.isNotEmpty) {
                  expenses.add(newExpense);
                  newExpense = '';
                }
              });
            },
            child:  Text('Add Expense'),
            color: Colors.blue,
            textColor: Colors.white,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(expenses[index]),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          RaisedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Back to Set Budget'),
          ),
        ],
      ),
    );
  }
}
// Data Models
class Budget {
  String name;
  double amount;
  Budget(this.name, this.amount);
}
class Expense {
  String name;
  double amount;
  String category;
  Expense(this.name, this.amount, this.category);
}
 // Start Implement Budget and Expense Screens
// Start set_budget_screen.dart
class SetBudgetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<BudgetProvider>(
        create: (context) => BudgetProvider(),
        child: Consumer<BudgetProvider>(
          builder: (context, budgetProvider, child) {
            return Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Budget Name'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Budget Amount'),
                ),
                ElevatedButton(
                  onPressed: () {
                    budgetProvider.addBudget();
                    Navigator.of(context).pushNamed('/record_expense');
                  },
                  child: Text('Submit Budget'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
} // End set_budget_screen.dart

// Start record_expense_screen.dart
class RecordExpenseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<ExpenseProvider>(
        create: (context) => ExpenseProvider(),
        child: Consumer<ExpenseProvider>(
          builder: (context, expenseProvider, child) {
            return Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Expense Name'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Expense Amount'),
                ),
                ElevatedButton(
                  onPressed: () {
                    expenseProvider.addExpense();
                  },
                  child: Text('Submit Expense'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
} // End record_expense_screen.dart

// End Implement Budget and Expense Screens

// Start Display Budgets and Expenses
// Start budget_list_screen.dart
class BudgetListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          return ListView.builder(
            itemCount: budgetProvider.budgets.length,
            itemBuilder: (context, index) {
              final budget = budgetProvider.budgets[index];
              return ListTile(
                title: Text(budget.name),
                subtitle: Text('Amount: \$${budget.amount.toStringAsFixed(2)}'),
              );
            },
          );
        },
      ),
    );
  }
} // End budget_list_screen.dart:

// Start expense_list_screen.dart:
class ExpenseListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          return ListView.builder(
            itemCount: expenseProvider.expenses.length,
            itemBuilder: (context, index) {
              final expense = expenseProvider.expenses[index];
              return ListTile(
                title: Text(expense.name),
                subtitle: Text('Amount: \$${expense.amount.toStringAsFixed(2)}'),
              );
            },
          );
        },
      ),
    );
  }
} // End expense_list_screen.dart

// Start Calculate Budget Progress

class BudgetProvider with ChangeNotifier {
  List<Budget> budgets = [];

  void addBudget(Budget budget) {
    budgets.add(budget);
    notifyListeners();
  }
}

class BudgetListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget List'),
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          return ListView.builder(
            itemCount: budgetProvider.budgets.length,
            itemBuilder: (context, index) {
              final budget = budgetProvider.budgets[index];
              final totalExpenses = _calculateTotalExpenses(budget);
              final remainingAmount = budget.amount - totalExpenses;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(budget.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: \$${budget.amount.toStringAsFixed(2)}'),
                      Text('Remaining: \$${remainingAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  double _calculateTotalExpenses(Budget budget) {
    // Replace this with your logic to calculate the total expenses for a budget.
    // For example, you can use a provider for expenses and sum them up.
    double totalExpenses = 0.0;
    // Add your logic here to calculate the total expenses for the budget.
    return totalExpenses;
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BudgetProvider()),
      ],
      child: MaterialApp(
        initialRoute: '/budget_list',
        routes: {
          '/budget_list': (context) => BudgetListScreen(),
        },
      ),
    ),
  );
}
//End of Calculate Budget Progress

// Start on Expense Analysis
class ExpenseProvider with ChangeNotifier {
  List<Expense> expenses = [];

  void addExpense(Expense expense) {
    expenses.add(expense);
    notifyListeners();
  }
}

class ExpenseAnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Analytics'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1.5,
                  child: PieChart(
                    PieChartData(
                      sections: _generateChartSections(expenseProvider.expenses),
                      centerSpaceRadius: 40.0,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _generateChartSections(List<Expense> expenses) {
    Map<String, double> categoryTotals = {};

    // Calculate total expenses for each category
    for (var expense in expenses) {
      if (categoryTotals.containsKey(expense.category)) {
        categoryTotals[expense.category] += expense.amount;
      } else {
        categoryTotals[expense.category] = expense.amount;
      }
    }

    // Generate chart sections
    List<PieChartSectionData> sections = [];
    int index = 0;
    for (var category in categoryTotals.keys) {
      sections.add(
        PieChartSectionData(
          color: Colors.primaries[index % Colors.primaries.length],
          value: categoryTotals[category],
          title: category,
          radius: 50,
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
          ),
        ),
      );
      index++;
    }

    return sections;
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ExpenseProvider()),
      ],
      child: MaterialApp(
        initialRoute: '/expense_analytics',
        routes: {
          '/expense_analytics': (context) => ExpenseAnalyticsScreen(),
        },
      ),
    ),
  );
}
// End of Expense Analytics

// Start of  Saving Goals, Income & Payment Tracking
// Start Create models
class SavingsGoal {
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String name;
  final double amount;

  SavingsGoal({required this.name, required this.amount});
  SavingsGoal({required this.title, required this.targetAmount, this.currentAmount = 0.0});
}

class Income {
  final String source;
  final double amount;

  Income({required this.source, required this.amount});
}

class Payment {
  final String description;
  final double amount;
  final DateTime date;

  Payment({required this.description, required this.amount, required this.date});
}  // End of creating models

//provider classes for Savings, Income, and Payment
//added data preference
class SavingsProvider with ChangeNotifier {
  List<SavingsGoal> _savingsGoals = [];
  List<SavingsGoal> get savingsGoals => _savingsGoals;

  // Start with data persistence
  // Key for storing savings goals in SharedPreferences
  static const _savingsKey = 'savingsKey';

  SavingsProvider() {
    // Initialize and load savings goals from SharedPreferences
    _loadSavings();
  }

  // Load savings goals from SharedPreferences
  Future<void> _loadSavings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSavings = prefs.getStringList(_savingsKey);

    if (savedSavings != null) {
      _savingsGoals = savedSavings
          .map((savings) {
        final parts = savings.split('|');
        return SavingsGoal(name: parts[0], amount: double.parse(parts[1]));
      })
          .toList();

      notifyListeners();
    }
  }

  // Save savings goals to SharedPreferences
  Future<void> _saveSavings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _savingsGoals
        .map((goal) => '${goal.name}|${goal.amount.toStringAsFixed(2)}')
        .toList();
    await prefs.setStringList(_savingsKey, data);
  }

  // Method to add a new savings goal
  void addSavingsGoal(SavingsGoal goal) {
    _savingsGoals.add(goal);
    _saveSavings(); // Save to SharedPreferences
    notifyListeners();
  }

  // Method to remove a savings goal
  void removeSavingsGoal(int index) {
    _savingsGoals.removeAt(index);
    _saveSavings(); // Save to SharedPreferences
    notifyListeners();
  }
  // End with data persistence saving goals
  }

//Start with data persistence income provider

class IncomeProvider with ChangeNotifier {
  double _income = 0.0;
  double get income => _income;

  // Key for storing income in SharedPreferences
  static const _incomeKey = 'incomeKey';

  IncomeProvider() {
    // Initialize and load income from SharedPreferences
    _loadIncome();
  }

  // Load income from SharedPreferences
  Future<void> _loadIncome() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIncome = prefs.getDouble(_incomeKey);

    if (savedIncome != null) {
      _income = savedIncome;
      notifyListeners();
    }
  }

  // Save income to SharedPreferences
  Future<void> _saveIncome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_incomeKey, _income);
  }

  // Method to set income
  void setIncome(double amount) {
    _income = amount;
    _saveIncome(); // Save to SharedPreferences
    notifyListeners();
  }
}

//End with data persistence income provider

//Start with data persistence payment provider

class PaymentProvider with ChangeNotifier {
  double _totalPayment = 0.0;
  double get totalPayment => _totalPayment;

  // Key for storing payments in SharedPreferences
  static const _paymentKey = 'paymentKey';

  PaymentProvider() {
    // Initialize and load payments from SharedPreferences
    _loadPayments();
  }

  // Load payments from SharedPreferences
  Future<void> _loadPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPayment = prefs.getDouble(_paymentKey);

    if (savedPayment != null) {
      _totalPayment = savedPayment;
      notifyListeners();
    }
  }

  // Save payments to SharedPreferences
  Future<void> _savePayments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_paymentKey, _totalPayment);
  }

  // Method to add a payment
  void addPayment(double amount) {
    _totalPayment += amount;
    _savePayments(); // Save to SharedPreferences
    notifyListeners();
  }
}
//End with data persistence payment provider

// Wrap your app with the providers using MultiProvider

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SavingsProvider()),
        ChangeNotifierProvider(create: (context) => IncomeProvider()),
        ChangeNotifierProvider(create: (context) => PaymentProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}
// SavingsProvider in a widget to add and remove savings goals
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final savingsProvider = Provider.of<SavingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Savings Goals'),
      ),
      body: Column(
        children: [
          // Display savings goals
          ListView.builder(
            itemCount: savingsProvider.savingsGoals.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(savingsProvider.savingsGoals[index].name),
                subtitle: Text('\$${savingsProvider.savingsGoals[index].amount.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    savingsProvider.removeSavingsGoal(index);
                  },
                ),
              );
            },
          ),

          // Add a new savings goal
          ElevatedButton(
            onPressed: () {
              savingsProvider.addSavingsGoal(SavingsGoal(name: 'New Goal', amount: 100.0));
            },
            child: Text('Add Savings Goal'),
          ),
        ],
      ),
    );
  }
}

// Start Saving goal screen

class SetSavingsGoalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final savingsProvider = Provider.of<SavingsProvider>(context);
    final TextEditingController goalNameController = TextEditingController();
    final TextEditingController goalAmountController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Set Savings Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: goalNameController,
              decoration: InputDecoration(labelText: 'Goal Name'),

            ),
            SizedBox(height: 10),
            TextField(
              controller: goalAmountController,
              decoration: InputDecoration(labelText: 'Amount (\$)'),
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyTextInputFormatter()],//Formatting Currency
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final String goalName = goalNameController.text;
                final double goalAmount = double.parse(goalAmountController.text);

                if (goalName.isNotEmpty && goalAmount > 0) {
                  savingsProvider.addSavingsGoal(
                    SavingsGoal(name: goalName, amount: goalAmount),
                  );
                  Navigator.pop(context);
                } else {
                  // Show an error message or validation feedback to the user.
                }
              },
              child: Text('Save Goal'),
            ),
            //Start of display saving goals
            SizedBox(height: 20),
            // Display the list of savings goals using ListView.builder
            Expanded(
              child: ListView.builder(
                itemCount: savingsProvider.savingsGoals.length,
                itemBuilder: (context, index) {
                  final goal = savingsProvider.savingsGoals[index];
                  return ListTile(
                    title: Text(goal.name),
                    subtitle: Text('\$${goal.amount.toStringAsFixed(2)}'),
                    // Add an option to delete the goal if needed
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} //

// End Saving goal screen and functionality

// Start tracking income screen and functionality

class TrackIncomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final incomeProvider = Provider.of<IncomeProvider>(context);
    final TextEditingController incomeAmountController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Track Income'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: incomeAmountController,
              decoration: InputDecoration(labelText: 'Income Amount (\$)'),
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyTextInputFormatter()],//Formatting Currency
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final double incomeAmount = double.parse(incomeAmountController.text);

                if (incomeAmount > 0) {
                  incomeProvider.setIncome(incomeAmount);
                  Navigator.pop(context);
                } else {
                  // Show an error message or validation feedback to the user.
                }
              },
              child: Text('Track Income'),
            ),
            //Start of displaying income tracking
            SizedBox(height: 20),
            // Display the list of income sources using ListView.builder
            Expanded(
              child: ListView.builder(
                itemCount: 1, // Update the itemCount as needed
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Income Source Name'), // Replace with actual data
                    subtitle: Text('\$${incomeProvider.income.toStringAsFixed(2)}'),
                    // Add an option to edit or delete income sources if needed
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//End of Tracking income screen and functionality

// Starting of Recording Payments Screen and functionaliyty

class RecordPaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final TextEditingController paymentDescriptionController = TextEditingController();
    final TextEditingController paymentAmountController = TextEditingController();
    final TextEditingController paymentDateController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Record Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: paymentDescriptionController,
              decoration: InputDecoration(labelText: 'Payment Description'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: paymentAmountController,
              decoration: InputDecoration(labelText: 'Amount (\$)'),
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyTextInputFormatter()],//Formatting Currency
            ),
            SizedBox(height: 10),
            TextField(
              controller: paymentDateController,
              decoration: InputDecoration(labelText: 'Date'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final String description = paymentDescriptionController.text;
                final double amount = double.parse(paymentAmountController.text);
                final String date = paymentDateController.text;

                if (description.isNotEmpty && amount > 0 && date.isNotEmpty) {
                  // You can handle the date as needed
                  paymentProvider.addPayment(amount);
                  Navigator.pop(context);
                } else {
                  // Show an error message or validation feedback to the user.
                }
              },
              child: Text('Record Payment'),
            ),
            SizedBox(height: 20),
            // Display the list of payments using ListView.builder
            Expanded(
              child: ListView.builder(
                itemCount: 1, // Update the itemCount as needed
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Payment Description'), // Replace with actual data
                    subtitle: Text('\$${paymentProvider.totalPayment.toStringAsFixed(2)}'),
                    // Add an option to edit or delete payments if needed
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//End of Recording Payments screen and functionality



//Start of the Investment Tracking for Businesses and Individuals







import 'package:intl/intl.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/material.dart';
import 'investment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart'; 
import 'package:firebase_core/firebase_core.dart';

//Investment Tracking for Businesses and Individuals

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();


// Bloc Events
abstract class NavigationEvent {}

class NavigateToInvestmentList extends NavigationEvent {}

// Bloc
class NavigationCubit extends Cubit<NavigationEvent> {
  NavigationCubit() : super(NavigateToInvestmentList());

  void navigateToInvestmentList() {
    emit(NavigateToInvestmentList());
  }
}
// End of Bloc

class ProviderScope {
}

class Investment {
  String name;
  String type;
  double amount;
  DateTime date;
  double currentValue;

  Investment({
    required this.name,
    required this.type,
    required this.amount,
    required this.date,
    required this.currentValue,
  });
  double getReturns() {
    return currentValue - amount;
  }
  double calculateROI() {
    if (amount == 0) {
      return 0.0; // Avoid division by zero
    }
    return ((currentValue - amount) / amount) * 100;
  }
} //Investment Class
  // River implement state management using riverpod
final investmentsProvider = StateNotifierProvider<InvestmentsNotifier, List<Investment>>(
      (ref) => InvestmentsNotifier(),
);

class InvestmentsNotifier extends StateNotifier<List<Investment>> {
  InvestmentsNotifier() : super([]);

  void setInvestments(List<Investment> newInvestments) {
    state = newInvestments;
  }

  void addInvestment(Investment investment) {
    state = [...state, investment];
  }

  Future<void> loadInvestments() async {
    // Fetch investments from Firestore
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore.collection('investments').get();
    state = querySnapshot.docs
        .map((doc) => Investment(
      name: doc['name'],
      type: doc['type'],
      amount: doc['amount'].toDouble(),
      date: (doc['date'] as Timestamp).toDate(),
      currentValue: doc['currentValue'].toDouble(),
    ))
        .toList();
  }
}
// End implement state management using riverpod

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InvestmentListScreen(),
    );
  } //Build App
} //Main App

//Class MyApp BLOC

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => NavigationCubit(),
        child: NavigationWrapper(),
      ),
    );
  }
}

class NavigationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationEvent>(
      builder: (context, state) {
        if (state is NavigateToInvestmentList) {
          return InvestmentListScreen();
        }
        return InitialScreen(); //  replaced this with initial screen
      },
    );
  }
}

class InitialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Investments App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Explore Your Investments',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<NavigationCubit>().navigateToInvestmentList();
              },
              child: Text('View Investments'),
            ),
          ],
        ),
      ),
    );
  }
}

//End of BLOC

//Class MyApp BLOC

class InvestmentListScreen extends StatefulWidget {
  @override
  _InvestmentListScreenState createState() => _InvestmentListScreenState();
}

class _InvestmentListScreenState extends State<InvestmentListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Investment> investments = []; //Investment List

  @override
  void initState() {
    super.initState();
    _loadInvestments();
  } //Initialize Investment List

  Future<void> _loadInvestments() async {
    // Fetch investments from Firestore
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await _firestore.collection('investments').get();
    investments = querySnapshot.docs
        .map((doc) =>
        Investment(
          name: doc['name'],
          type: doc['type'],
          amount: doc['amount'].toDouble(),
          date: (doc['date'] as Timestamp).toDate(),
          currentValue: doc['currentValue'].toDouble(),
        ))
        .toList();

    setState(() {});
  } //Load Investment List

  //Starting Graphs
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Investments'),
      ),
      body: Column(
        children: [
          // Line Chart
          Container(
            height: 300,
            padding: EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xff37434d), width: 1),
                ),
                minX: 0,
                maxX: investments.length.toDouble() - 1,
                minY: 0,
                maxY: _calculateMaxY(),
                // Function to calculate the maximum Y value
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateSpots(),
                    isCurved: true,
                    colors: [Colors.blue],
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          // Investment List
          Expanded(
            child: ListView.builder(
              itemCount: investments.length,
              itemBuilder: (context, index) {
                Investment investment = investments[index];
                return ListTile(
                  title: Text(investment.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${investment.type} - ${investment.date}'),
                      Text(
                          'Returns: \$${investment.getReturns().toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: Text('Current Value: \$${investment.currentValue.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddInvestmentDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  // Helper function to generate data points for the line chart
  List<FlSpot> _generateSpots() {
    return investments
        .asMap()
        .entries
        .map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.currentValue);
    }).toList();
  }

  // Helper function to calculate the maximum Y value for the line chart
  double _calculateMaxY() {
    if (investments.isEmpty) {
      return 0;
    }
    return investments.map((investment) => investment.currentValue).reduce((a,
        b) => a > b ? a : b) + 100;
  }

  //End Graphs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Investments'),
      ),
      body: ListView.builder(
        itemCount: investments.length,
        itemBuilder: (context, index) {
          Investment investment = investments[index];
          return ListTile(
            title: Text(investment.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${investment.type} - ${investment.date}'),
                Text(
                    'Returns: \$${investment.getReturns().toStringAsFixed(2)}'),
              ],
            ),
            trailing: Text(
                'Current Value: \$${investment.currentValue.toStringAsFixed(
                    2)}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddInvestmentDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Investments'),
      ),
      body: ListView.builder(
        itemCount: investments.length,
        itemBuilder: (context, index) {
          Investment investment = investments[index];
          return ListTile(
            title: Text(investments[index].name),
            subtitle: Text(
                '${investments[index].type} - ${investments[index].date}'),
            trailing: Text('Current Value: \$${investments[index].currentValue
                .toStringAsFixed(2)}'),
          );
        }, //Display Investment List
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddInvestmentDialog(context),
        child: Icon(Icons.add),
      ),
    );
  } //Build Investment List Screen

  // Start InvestmentListScreen to Display ROI

  class InvestmentListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
  final investments = watch(investmentsProvider);

        return Scaffold(
            appBar: AppBar(
              title: Text('Investments'),
  ),
            body: Column(
               children: [
                // Line Chart
                 //Just added this to the container
                  Container(
                 height: 300,
                  padding: EdgeInsets.all(16.0),
                      child: LineChart(
                      LineChartData(
                   gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: true),
                     borderData: FlBorderData(
                     show: true,
                   border: Border.all(color: const Color(0xff37434d), width: 1),
             ),
                  minX: 0,
                   maxX: investments.length.toDouble() - 1,
                   minY: 0,
                   maxY: 100, // Adjust maxY according to your data
                  lineBarsData: [
                    LineChartBarData(
                  spots: _generateLineChartSpots(investments),
                   isCurved: true,
                   colors: [Colors.blue],
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                  ),
                  ],
  ),
  ),
  ),
  //Just added this to the container
  // Investment List
                Expanded(
                  child: ListView.builder(
                  itemCount: investments.length,
                   itemBuilder: (context, index) {
                  Investment investment = investments[index];
                   return ListTile(
                   title: Text(investment.name),
                     subtitle: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                      Text('${investment.type} - ${investment.date}'),
                       Text(
                     'Returns: \$${investment.getReturns().toStringAsFixed(2)}'),
                        Text('ROI: ${investment.calculateROI().toStringAsFixed(2)}%'),
  ],
  ),
                     trailing: Text('Current Value: \$${investment.currentValue.toStringAsFixed(2)}'),
  );
  },
  ),
  ),
  ],
  ),
              floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddInvestmentDialog(context),
                 child: Icon(Icons.add),
  ),
  );
  }

  // End InvestmentListScreen to Display ROI

  // Start of Graphical Representation for ROI
  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
  title: Text('Investments'),
  ),
  body: Column(
  children: [
  // Line Chart
  Container(
  height: 300,
  padding: EdgeInsets.all(16.0),
  child: LineChart(
  LineChartData(
  // ... (existing line chart configuration)
  ),
  ),
  ),
  // Bar Chart for ROI
  Container(
  height: 300,
  padding: EdgeInsets.all(16.0),
  child: BarChart(
  BarChartData(
  gridData: FlGridData(show: false),
  titlesData: FlTitlesData(show: true),
  borderData: FlBorderData(
  show: true,
  border: Border.all(color: const Color(0xff37434d), width: 1),
  ),
  groupsSpace: 12.0,
  barGroups: _generateROIChartData(investments),
  ),
  ),
  ),
  // Investment List
  Expanded(
  child: ListView.builder(
  itemCount: investments.length,
  itemBuilder: (context, index) {
  Investment investment = investments[index];
  return ListTile(
  title: Text(investment.name),
  subtitle: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text('Type: ${investment.type}'),
  Text('Date: ${DateFormat('yyyy-MM-dd').format(investment.date)}'), // Date formatting
  Text('Returns: \$${investment.getReturns().toStringAsFixed(2)}'),
  Text('ROI: ${investment.calculateROI().toStringAsFixed(2)}%'),
  ],
  ),
  trailing: Text('Current Value: \$${investment.currentValue.toStringAsFixed(2)}'),
  );
  },
  ),
  ),
  // Add Investment Form
  _buildAddInvestmentForm(context),
  ],
  ),
  );
  }
  floatingActionButton: FloatingActionButton(
  onPressed: () => _showAddInvestmentDialog(context),
  child: Icon(Icons.add),
  ),
  );
  }
 //Start fl_chart
 List<FlSpot> _generateLineChartSpots(List<Investment> investments) {
  return investments.asMap().entries.map((entry) {
  return FlSpot(entry.key.toDouble(), entry.value.calculateROI());
  }).toList();
  }
 //End of fl_chart
  // Helper function to generate data points for the bar chart
  List<BarChartGroupData> _generateROIChartData(List<Investment> investments) {
  return investments.asMap().entries.map((entry) {
  return BarChartGroupData(
  x: entry.key.toDouble(),
  barRods: [
  BarChartRodData(
  y: entry.value.calculateROI(),
  colors: [Colors.blue],
  ),
  ],
  );
  }).toList();
  }
  //Integrate the form into the InvestmentListScreen
  Widget _buildAddInvestmentForm(BuildContext context) {
  return Padding(
  padding: const EdgeInsets.all(16.0),
  child: FormBuilder(
  key: _formKey,
  autovalidateMode: AutovalidateMode.onUserInteraction,
  child: Column(
  children: [
  FormBuilderTextField(
  name: 'name',
  decoration: InputDecoration(labelText: 'Name'),
  validator: FormBuilderValidators.required(context),
  ),
  FormBuilderTextField(
  name: 'type',
  decoration: InputDecoration(labelText: 'Type'),
  validator: FormBuilderValidators.required(context),
  ),
  FormBuilderTextField(
  name: 'amount',
  decoration: InputDecoration(labelText: 'Amount'),
  validator: FormBuilderValidators.compose([
  FormBuilderValidators.required(context),
  FormBuilderValidators.numeric(context),
  ]),
  ),
  FormBuilderDateTimePicker(
  name: 'date',
  inputType: InputType.date,
  format: DateFormat('yyyy-MM-dd'),
  decoration: InputDecoration(labelText: 'Date'),
  validator: FormBuilderValidators.required(context),
  ),
  SizedBox(height: 16.0),
  ElevatedButton(
  onPressed: () {
  if (_formKey.currentState!.saveAndValidate()) {
  // Adding logic to handle the form data and save the investment
  _handleFormSubmission(_formKey.currentState!.value);
  }
  },
  child: Text('Add Investment'),
  ),
  ],
  ),
  ),
  );
  }
//_handleFormSubmission function to save the new investment to Firebase Firestore
  Future<void> _handleFormSubmission(Map<String, dynamic> formData) async {
  try {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new investment object
  Investment newInvestment = Investment(
  name: formData['name'],
  type: formData['type'],
  amount: double.parse(formData['amount']),
  date: formData['date'],
  currentValue: 0.0, // You might want to set this initially to 0, or fetch it from another source
  );

  // Add the new investment to Firestore
  await _firestore.collection('investments').add({
  'name': newInvestment.name,
  'type': newInvestment.type,
  'amount': newInvestment.amount,
  'date': newInvestment.date,
  'currentValue': newInvestment.currentValue,
  });

  // Update the state to include the new investment
  context.read(investmentsProvider.notifier).addInvestment(newInvestment);

  // Navigate to the investment list screen
  context.read<NavigationCubit>().navigateToInvestmentList();
  } catch (error) {
  // Handle errors (e.g., show an error message)
  print('Error submitting form: $error');
  }
  }
 //_handleFormSubmission function to save the new investment to Firebase Firestore:
  //Integrate the form into the InvestmentListScreen
  // End of Graphical Representation for ROI

  Future<void> _showAddInvestmentDialog(BuildContext context) async {
  Investment newInvestment = Investment(
  name: '',
  type: '',
  amount: 0.0,
  date: DateTime.now(),
  currentValue: 0.0,
  );

  await showDialog(
  context: context,
  builder: (context) {
  return AlertDialog(
  title: Text('Add Investment'),
  content: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
  TextField(
  decoration: InputDecoration(labelText: 'Name'),
  onChanged: (value) => newInvestment.name = value,
  ),
  TextField(
  decoration: InputDecoration(labelText: 'Type'),
  onChanged: (value) => newInvestment.type = value,
  ),
  TextField(
  decoration: InputDecoration(labelText: 'Amount'),
  keyboardType: TextInputType.number,
  onChanged: (value) => newInvestment.amount = double.parse(value),
  ),
  TextField(
  decoration: InputDecoration(labelText: 'Date'),
  readOnly: true,
  onTap: () async {
  DateTime selectedDate = await showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2000),
  lastDate: DateTime(2101),
  ); //Show Date Picker
  if (selectedDate != null && selectedDate != newInvestment.date) {
  setState(() {
  newInvestment.date = selectedDate;
  });
  }
  },
  controller: TextEditingController(text: newInvestment.date.toString()),
  ),
  ],//Add Investment Form
  ),
  actions: [
  TextButton(
  onPressed: () => Navigator.pop(context),
  child: Text('Cancel'),
  ),
  TextButton(
  onPressed: () async {
  await _addInvestment(newInvestment);
  Navigator.pop(context);
  },
  child: Text('Add'),
  ),
  ],
  );
  },
  ); //Show Dialog
  }

  Future<void> _addInvestment(Investment investment) async {
  // Add investment to Firestore
  await _firestore.collection('investments').add({
  'name': investment.name,
  'type': investment.type,
  'amount': investment.amount,
  'date': investment.date,
  'currentValue': investment.currentValue,
  });

  _loadInvestments();
   }
   }

//End Investment Tracking for Businesses and Individuals


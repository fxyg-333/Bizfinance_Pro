import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';
import 'package:flutter/material.dart';



void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DTOSearch(),
    );
  }
}
class DTOSearch extends StatefulWidget {
  const DTOSearch({Key? key}) : super(key: key);

  @override
  State<DTOSearch> createState() => _DTOSearchState();
}

class _DTOSearchState extends State<DTOSearch> {
  final TextEditingController controller = TextEditingController(text: 'GOOG');
  late Future<YahooFinanceResponse> future;



  //
  @override
  void initState() {
  super.initState();
  load();
  }
  void load() {
  // Loading Stock Summary
  future = YahooFinanceStockSummaryDataReader().getStockSummary(controller.text);

  setState(() {});
  }
  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
  title: Text('Yahoo Finance Stock Summary Example'),
  ),
  body: Column(
  children: [
  const Text('Enter Ticker Symbol:'),
  TextField(
  controller: controller,
  ),
  ElevatedButton(
  onPressed: load,
  child: const Text('Load Stock Summary'),
  ),
  Expanded(
  child: FutureBuilder(
  future: future,
  builder: (BuildContext context, AsyncSnapshot<YahooFinanceResponse> snapshot) {
  if (snapshot.connectionState == ConnectionState.done) {
  if (snapshot.hasError) {
  return Text('Error: ${snapshot.error}');
  }

  if (snapshot.data == null) {
  return const Text('No data');
  }

  YahooFinanceResponse response = snapshot.data!;
  // Display your stock summary data here
  return Text(response.toString());
  } else {
  return const Center(
  child: CircularProgressIndicator(),
  );
  }
  },
  ),
  ),
  ],
  ),
  );
  }
// End Loading Stock Summary


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Ticker from yahoo finance'),
        TextField(
          controller: controller,
        ),
        MaterialButton(
          onPressed: load,
          child: const Text('Load'),
          color: Theme.of(context).primaryColor,
        ),
        Expanded(
          child: FutureBuilder(
            future: future,
            builder: (BuildContext context,
                AsyncSnapshot<YahooFinanceResponse> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null) {
                  return const Text('No data');
                }

                YahooFinanceResponse response = snapshot.data!;
                return ListView.builder(
                  itemCount: response.candlesData.length,
                  itemBuilder: (BuildContext context, int index) {
                    YahooFinanceCandleData candle = response.candlesData[index];
                    return _CandleCard(candle);
                  },
                );
              } else {
                return const Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void load() {
    // Use different readers for various financial data
    // Example: Loading historical quotes
    future = YahooFinanceHistoricalDataReader().getHistoricalQuotes(
      controller.text,
      start: DateTime.now().subtract(Duration(days: 365)),
      end: DateTime.now(),
      interval: YahooFinanceInterval.DAY,
    );
    setState(() {});
  }
}

class _CandleCard extends StatelessWidget {
  final YahooFinanceCandleData candle;
  const _CandleCard(this.candle);

  @override
  Widget build(BuildContext context) {
    final String date = candle.date.toIso8601String().split('T').first;

    return Card(
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(date),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('open: ${candle.open.toStringAsFixed(2)}'),
                Text('close: ${candle.close.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('low: ${candle.low.toStringAsFixed(2)}'),
                Text('high: ${candle.high.toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// Loading Company Profile
class _DTOSearchState extends State<DTOSearch> {
  final TextEditingController controller = TextEditingController(text: 'AAPL'); // AAPL is Apple
  late Future<YahooFinanceCompanyProfile> future;


  // Loading Company Profile
  void load() {
    // Loading Company Profile
    future = YahooFinanceCompanyProfileDataReader().getCompanyProfile(controller.text);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yahoo Finance Company Profile'),
      ),
      body: Column(
        children: [
          const Text('Enter Ticker Symbol:'),
          TextField(
            controller: controller,
          ),
          ElevatedButton(
            onPressed: load,
            child: const Text('Load Company Profile'),
          ),
          Expanded(
            child: FutureBuilder(
              future: future,
              builder: (BuildContext context, AsyncSnapshot<YahooFinanceCompanyProfile> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.data == null) {
                    return const Text('No data');
                  }

                  YahooFinanceCompanyProfile companyProfile = snapshot.data!;
                  // Display your company profile data here
                  return Text(
                      'CompanyName: ${companyProfile.companyName}\n'
                          'Industry: ${companyProfile.industry}\n'
                          'Description: ${companyProfile.description}\n'
                    // Add more fields as needed
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
// End Loading Company Profile



// Loading Financial Statements

class _DTOSearchState extends State<DTOSearch> {
  final TextEditingController controller = TextEditingController(text: 'AAPL'); // Example ticker: AAPL
  late Future<YahooFinanceFinancialStatements> future;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() {
    // Loading Financial Statements
    future = YahooFinanceFinancialStatementsDataReader().getFinancialStatements(controller.text);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yahoo Finance Financial Statements Example'),
      ),
      body: Column(
        children: [
          const Text('Enter Ticker Symbol:'),
          TextField(
            controller: controller,
          ),
          ElevatedButton(
            onPressed: load,
            child: const Text('Load Financial Statements'),
          ),
          Expanded(
            child: FutureBuilder(
              future: future,
              builder: (BuildContext context, AsyncSnapshot<YahooFinanceFinancialStatements> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.data == null) {
                    return const Text('No data');
                  }

                  YahooFinanceFinancialStatements financialStatements = snapshot.data!;
                  // Display your financial statements data here
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Balance Sheet: ${financialStatements.balanceSheet}'),
                      Text('Income Statement: ${financialStatements.incomeStatement}'),
                      Text('Cash Flow Statement: ${financialStatements.cashFlowStatement}'),
                      // Add more fields as needed
                    ],
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
// End Loading Financial Statements

// Loading Analyst Recommendations


class _DTOSearchState extends State<DTOSearch> {
  final TextEditingController controller = TextEditingController(text: 'AAPL'); // Example ticker: AAPL
  late Future<YahooFinanceAnalystRecommendations> future;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() {
    // Loading Analyst Recommendations
    future = YahooFinanceAnalystRecommendationsDataReader().getAnalystRecommendations(controller.text);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yahoo Finance Analyst Recommendations Example'),
      ),
      body: Column(
        children: [
          const Text('Enter Ticker Symbol:'),
          TextField(
            controller: controller,
          ),
          ElevatedButton(
            onPressed: load,
            child: const Text('Load Analyst Recommendations'),
          ),
          Expanded(
            child: FutureBuilder(
              future: future,
              builder: (BuildContext context, AsyncSnapshot<YahooFinanceAnalystRecommendations> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.data == null) {
                    return const Text('No data');
                  }

                  YahooFinanceAnalystRecommendations analystRecommendations = snapshot.data!;
                  // Display your analyst recommendations data here
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Strong Buy: ${analystRecommendations.strongBuy}'),
                      Text('Buy: ${analystRecommendations.buy}'),
                      Text('Hold: ${analystRecommendations.hold}'),
                      Text('Sell: ${analystRecommendations.sell}'),
                      Text('Strong Sell: ${analystRecommendations.strongSell}'),
                      // Add more fields as needed
                    ],
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
// End Loading Analyst Recommendations

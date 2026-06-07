import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real-Time Feature Flag Demo',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = false;
  bool showAiRecommendations = true;
  bool useNewCheckout = false;
  String welcomeMessage = "Connecting to Local Sync...";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Poll the cloud sync pipeline every 1 second for sub-second UI updates
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _fetchCloudFlags());
  }

  Future<void> _fetchCloudFlags() async {
    try {
      final response = await http.get(Uri.parse('https://kvstore.io/api/collections/avani_singh/items/feature_flags'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // Extract inner values from KVstore wrapper structure
        final Map<String, dynamic> configStore = jsonDecode(data['value']);
        final flags = configStore['flags'] ?? {};
        final configs = configStore['configs'] ?? {};

        setState(() {
          useNewCheckout = flags['new_checkout_flow']?['status'] ?? false;
          isDarkMode = flags['dark_mode_beta']?['status'] ?? false;
          showAiRecommendations = flags['ai_recommendations']?['status'] ?? false;
          welcomeMessage = configs['welcome_message'] ?? "Welcome to the App!";
        });
      }
    } catch (e) {
      debugPrint("Sync Error: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🔌 Live Cloud Sync Client'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                welcomeMessage,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (showAiRecommendations)
                Card(
                  color: isDarkMode ? Colors.amber.shade900 : Colors.amber.shade100,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      '✨ AI Recommendations Feature is [ACTIVE]',
                      style: TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: useNewCheckout ? Colors.green : Colors.blue,
                ),
                child: Text(
                  useNewCheckout ? 'Proceed to New Checkout 🚀' : 'Standard Checkout 🛒',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
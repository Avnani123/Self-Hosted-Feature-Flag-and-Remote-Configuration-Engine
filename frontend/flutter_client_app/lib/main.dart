import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'import_convert_fallback.dart'; // Handles clean string parsing

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real-Time Feature Flag Demo',
      theme: ThemeData.light(),
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
  // Connect directly to your local Python FastAPI server socket
  final WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse('ws://10.0.2.2:8000/ws'), // Use '10.0.2.2' for Android Emulator, or 'localhost' for Web/iOS
  );

  // Safe default application fallback states
  bool isDarkMode = false;
  bool showAiRecommendations = true;
  bool useNewCheckout = false;
  String welcomeMessage = "Welcome to the App!";

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _channel.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          try {
            // Process the inbound JSON payload broadcasted by the Python server
            final Map<String, dynamic> data = jsonDecode(snapshot.data.toString());
            final flags = data['flags'] ?? {};
            final configs = data['configs'] ?? {};

            // Dynamically assign local variables based on the live engine state
            useNewCheckout = flags['new_checkout_flow']?['status'] ?? false;
            isDarkMode = flags['dark_mode_beta']?['status'] ?? false;
            showAiRecommendations = flags['ai_recommendations']?['status'] ?? false;
            welcomeMessage = configs['welcome_message'] ?? welcomeMessage;
          } catch (e) {
            debugPrint("Error parsing remote config: $e");
          }
        }

        return Theme(
          data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('🔌 Live Remote Engine Client'),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              key: ValueKey(isDarkMode), // Forces swift redraw when theme shifts
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Dynamic Config Text
                  Text(
                    welcomeMessage,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // 2. Conditional UI Feature Render 
                  if (showAiRecommendations)
                    Card(
                      color: Colors.amber.shade100,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          '✨ AI Recommendations Feature is [ACTIVE]',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // 3. Alternate Flow Feature Switch
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
      },
    );
  }
}
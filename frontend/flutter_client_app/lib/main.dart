import 'package:flutter/material.dart';
import 'dart:math';
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
      title: 'Enterprise Remote Config Engine',
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
  // ==========================================
  // 1. ENGINE STATES (DEFAULT FALLBACKS)
  // ==========================================
  bool serverDarkModeFlag = false;
  bool serverAiRecommendationsFlag = true;
  bool serverNewCheckoutFlag = true;
  bool serverAbTestFlag = true;
  int maxLoginAttemptsConfig = 5;

  bool isCurrentUserBetaTester = false;
  String assignedAbVariant = 'A';

  int variantAClicks = 0;
  int variantBClicks = 0;
  List<String> liveAnalyticsLogs = ["System Initialized."];
  bool isPanelExpanded = true;

  // ==========================================
  // 2. LIVE NETWORKING CONNECTION CONFIG
  // ==========================================
  Timer? _networkSyncTimer;

  // ✅ FIXED: Updated to use your authenticated live tunnel URL path
  final String backendStreamUrl = "https://big-cloths-stick.loca.lt/flags";

  bool get isDarkMode => serverDarkModeFlag;
  bool get showAiRecommendations => serverAiRecommendationsFlag;

  // ✅ OVERRIDING LOGIC: Terminal commands take absolute priority
  bool get useNewCheckout => serverNewCheckoutFlag;

  String get welcomeMessage =>
      isCurrentUserBetaTester ? "🎯 [BETA TESTER]" : "👤 [STANDARD USER]";

  @override
  void initState() {
    super.initState();
    _assignRandomAbVariant();

    // Start polling your VS Code Python server every 1.5 seconds automatically
    _networkSyncTimer =
        Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      _fetchLiveBackendData();
    });
  }

  Future<void> _fetchLiveBackendData() async {
    try {
      final response = await http.get(Uri.parse(backendStreamUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> liveData = json.decode(response.body);

        // This instantly re-renders your FlutLab app UI live when data changes in VS Code
        setState(() {
          serverNewCheckoutFlag = liveData['new_checkout_flow'] ?? false;
          serverDarkModeFlag = liveData['dark_mode_beta'] ?? false;
          serverAiRecommendationsFlag = liveData['ai_recommendations'] ?? false;
          maxLoginAttemptsConfig = liveData['max_login_attempts'] ?? 5;
        });
      }
    } catch (error) {
      // Catch network drops quietly without crashing the user interface
    }
  }

  @override
  void dispose() {
    _networkSyncTimer?.cancel(); // Clean up memory loop on closure
    super.dispose();
  }

  void _assignRandomAbVariant() {
    final random = Random();
    setState(() {
      assignedAbVariant = random.nextBool() ? 'A' : 'B';
      _logAnalytics("Assigned Variant [$assignedAbVariant]");
    });
  }

  void _logAnalytics(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    setState(() {
      liveAnalyticsLogs.insert(0, "[$timestamp] $message");
      if (liveAnalyticsLogs.length > 3) liveAnalyticsLogs.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('⚡ Config Control Plane',
              style: TextStyle(fontSize: 18)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: _assignRandomAbVariant,
            )
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 12.0,
                  bottom: isPanelExpanded ? 270.0 : 60.0,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildIdentityBanner(),
                      const SizedBox(height: 12),
                      _buildConfigVariableCard(),
                      const SizedBox(height: 12),
                      if (showAiRecommendations)
                        _buildAiRecommendationFeature(),
                      const SizedBox(height: 12),
                      _buildCheckoutButton(),
                      const SizedBox(height: 12),
                      if (serverAbTestFlag) _buildAbExperimentModule(),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildSimulationDashboard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUserBetaTester
            ? Colors.purple.withOpacity(0.12)
            : Colors.blue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isCurrentUserBetaTester ? Colors.purple : Colors.blue,
            width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              welcomeMessage,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: assignedAbVariant == 'A' ? Colors.teal : Colors.deepOrange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Group $assignedAbVariant",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildConfigVariableCard() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("LIVE CONFIG PROPERTIES",
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("max_login_attempts:",
                    style: TextStyle(fontSize: 13)),
                Text("$maxLoginAttemptsConfig",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                        fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiRecommendationFeature() {
    return Card(
      elevation: 2,
      color: isDarkMode
          ? Colors.amber.shade900.withOpacity(0.25)
          : Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.amber, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          children: [
            Text('✨ ', style: TextStyle(fontSize: 18)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Banner Active',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('Delivering real-time profile variations.',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return ElevatedButton(
      onPressed: () => _logAnalytics(
          "Checkout triggered via ${useNewCheckout ? 'New' : 'Legacy'} Flow"),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor:
            useNewCheckout ? Colors.green.shade600 : Colors.blue.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        useNewCheckout ? 'Proceed to New Checkout 🚀' : 'Standard Checkout 🛒',
        style: const TextStyle(
            fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAbExperimentModule() {
    bool isVariantB = (assignedAbVariant == 'B');
    return Card(
      elevation: 2,
      color: isVariantB
          ? Colors.deepOrange.withOpacity(0.02)
          : Colors.teal.withOpacity(0.02),
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: isVariantB ? Colors.deepOrange : Colors.teal, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("📊 AB TEST CONTEXT",
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                Text(isVariantB ? "VARIANT B" : "CONTROL A",
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isVariantB ? Colors.deepOrange : Colors.teal)),
              ],
            ),
            const SizedBox(height: 8),
            if (!isVariantB) ...[
              TextButton(
                onPressed: () {
                  setState(() => variantAClicks++);
                  _logAnalytics("Click on Control A");
                },
                child: const Text("Click Here to Learn More",
                    style: TextStyle(fontSize: 13)),
              )
            ] else ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8)),
                onPressed: () {
                  setState(() => variantBClicks++);
                  _logAnalytics("Click on Variant B");
                },
                child: const Text("CLAIM DISCOVER OFFER NOW 🔥",
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationDashboard() {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF121214) : Colors.grey.shade900,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => isPanelExpanded = !isPanelExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("🛠️ LOCAL WORKSPACE BYPASS OVERRIDE",
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade400)),
                  Icon(
                      isPanelExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: Colors.white70,
                      size: 18),
                ],
              ),
            ),
          ),
          if (isPanelExpanded) ...[
            const Divider(color: Colors.white24, height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildServerToggleChip(
                    label: "Dark Canvas",
                    isActive: serverDarkModeFlag,
                    onTap: () => setState(
                        () => serverDarkModeFlag = !serverDarkModeFlag)),
                _buildServerToggleChip(
                    label: "New Flow",
                    isActive: serverNewCheckoutFlag,
                    onTap: () => setState(
                        () => serverNewCheckoutFlag = !serverNewCheckoutFlag)),
                _buildServerToggleChip(
                    label: "AI Banner",
                    isActive: serverAiRecommendationsFlag,
                    onTap: () => setState(() => serverAiRecommendationsFlag =
                        !serverAiRecommendationsFlag)),
                _buildServerToggleChip(
                    label: "A/B Run",
                    isActive: serverAbTestFlag,
                    onTap: () =>
                        setState(() => serverAbTestFlag = !serverAbTestFlag)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() =>
                        isCurrentUserBetaTester = !isCurrentUserBetaTester),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: isCurrentUserBetaTester
                              ? Colors.purpleAccent
                              : Colors.grey.shade700),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                        isCurrentUserBetaTester
                            ? "🧪 Profile: Beta"
                            : "👤 Profile: Standard",
                        style: const TextStyle(fontSize: 10)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        maxLoginAttemptsConfig =
                            maxLoginAttemptsConfig == 5 ? 3 : 5;
                        _logAnalytics("max_logins -> $maxLoginAttemptsConfig");
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text("Max Logins: $maxLoginAttemptsConfig",
                        style: const TextStyle(fontSize: 10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 55,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(4)),
              child: ListView.builder(
                itemCount: liveAnalyticsLogs.length,
                itemBuilder: (context, i) {
                  return Text(liveAnalyticsLogs[i],
                      style: const TextStyle(
                          color: Colors.greenAccent,
                          fontFamily: 'monospace',
                          fontSize: 10));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                "A Metrics: $variantAClicks | B Metrics: $variantBClicks",
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildServerToggleChip(
      {required String label,
      required bool isActive,
      required VoidCallback onTap}) {
    return SizedBox(
      height: 28,
      child: ActionChip(
        label: Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        backgroundColor: isActive ? Colors.blue.shade700 : Colors.grey.shade800,
        padding: EdgeInsets.zero,
        pressElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onPressed: onTap,
      ),
    );
  }
}

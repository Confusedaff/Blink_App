import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const EyeStatusApp());
}

class EyeStatusApp extends StatefulWidget {
  const EyeStatusApp({super.key});

  @override
  State<EyeStatusApp> createState() => _EyeStatusAppState();
}

class _EyeStatusAppState extends State<EyeStatusApp> {
  bool? eyeClosed;
  Timer? timer;

  final String serverUrl = "http://172.18.122.160:5000/status";

  @override
  void initState() {
    super.initState();
    fetchStatus();
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      fetchStatus();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchStatus() async {
    try {
      final res = await http.get(Uri.parse(serverUrl));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          eyeClosed = data["status"];
        });
      }
    } catch (e) {
      debugPrint("Error fetching status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayText;
    Color displayColor;

    if (eyeClosed == null) {
      displayText = "Loading...";
      displayColor = Colors.grey;
    } else if (eyeClosed!) {
      displayText = "TRUE (Eyes Closed)";
      displayColor = Colors.green;
    } else {
      displayText = "FALSE (Eyes Open)";
      displayColor = Colors.red;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: 28,
              color: displayColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
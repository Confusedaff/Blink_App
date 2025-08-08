import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

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

  final List<String> videoUrls = [
    "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
    "https://sample-videos.com/video123/mp4/480/big_buck_bunny.mp4",
    "https://media.w3.org/2010/05/sintel/trailer.mp4",
  ];

  final List<VideoPlayerController> controllers = [];
  int currentPage = 0;

  @override
  void initState() {
    super.initState();

    // Init video controllers
    for (var i = 0; i < videoUrls.length; i++) {
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(videoUrls[i]))
            ..setLooping(true)
            ..setVolume(0) // mute for autoplay on web
            ..initialize().then((_) {
              setState(() {});
              if (i == 0) controlVideoPlayback(); // start first video if needed
            });
      controllers.add(controller);
    }

    // Poll API
    fetchStatus();
    timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      fetchStatus();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> fetchStatus() async {
    try {
      final res = await http.get(Uri.parse(serverUrl));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["status"] is bool) {
          eyeClosed = data["status"];
        } else {
          final statusString = data["status"].toString().toUpperCase().trim();
          eyeClosed = statusString.contains("CLOSED");
        }
        setState(() {});
        controlVideoPlayback();
      }
    } catch (e) {
      debugPrint("Error fetching status: $e");
    }
  }

  void controlVideoPlayback() {
    if (eyeClosed == null) return;
    final currentController = controllers[currentPage];

    if (!currentController.value.isInitialized) {
      // Wait until initialized before playing
      currentController.initialize().then((_) {
        if (eyeClosed!) currentController.play();
        setState(() {});
      });
      return;
    }

    if (eyeClosed!) {
      if (!currentController.value.isPlaying) currentController.play();
    } else {
      if (currentController.value.isPlaying) currentController.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: videoUrls.length,
          onPageChanged: (index) {
            controllers[currentPage].pause();
            setState(() => currentPage = index);
            controlVideoPlayback();
          },
          itemBuilder: (context, index) {
            final controller = controllers[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                controller.value.isInitialized
                    ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: controller.value.size.width,
                          height: controller.value.size.height,
                          child: VideoPlayer(controller),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      eyeClosed == null
                          ? "Loading..."
                          : eyeClosed!
                              ? "Eyes Closed → Playing"
                              : "Eyes Open → Paused",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
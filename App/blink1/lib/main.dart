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
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const VideoScreen(),
      const GameScreen(),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library),
              label: "Videos",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.videogame_asset),
              label: "Games",
            ),
          ],
        ),
      ),
    );
  }
}

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  bool? eyeClosed;
  Timer? timer;
  final String serverUrl = "http://172.18.122.160:5000/status";

  final List<String> videoUrls = [
    "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
    "https://media.w3.org/2010/05/sintel/trailer.mp4",
  ];

  final List<VideoPlayerController> controllers = [];
  int currentPage = 0;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < videoUrls.length; i++) {
      // ignore: deprecated_member_use
      final controller = VideoPlayerController.network(videoUrls[i]);
      controller
        ..setLooping(true)
        ..setVolume(0)
        ..initialize().then((_) {
          setState(() {});
          if (i == 0 && eyeClosed == true) {
            controller.play();
          }
        });
      controllers.add(controller);
    }

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
        bool? newStatus;
        if (data["status"] is bool) {
          newStatus = data["status"];
        } else {
          final statusString = data["status"].toString().toUpperCase().trim();
          newStatus = statusString.contains("CLOSED");
        }

        if (newStatus != eyeClosed) {
          setState(() {
            eyeClosed = newStatus;
          });
          controlVideoPlayback();
        }
      }
    } catch (e) {
      debugPrint("Error fetching status: $e");
    }
  }

  void controlVideoPlayback() {
    if (eyeClosed == null) return;
    final currentController = controllers[currentPage];
    if (!currentController.value.isInitialized) return;

    if (eyeClosed!) {
      if (!currentController.value.isPlaying) {
        currentController.play();
      }
    } else {
      if (currentController.value.isPlaying) {
        currentController.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            ],
          );
        },
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final String serverUrl = "http://172.18.122.160:5000/status";
  bool? eyeClosed;
  Timer? statusTimer;
  Timer? gameTimer;

  static const int rows = 20;
  static const int cols = 10;
  List<List<Color?>> grid =
      List.generate(rows, (_) => List.generate(cols, (_) => null));

  int currentRow = 0;
  int currentCol = 4;
  late List<List<int>> currentShape;
  late Color currentColor;

  int score = 0;

  double _panDxAccum = 0.0;
  double _panDyAccum = 0.0;
  bool _dragMoved = false;
  final double _dragThreshold = 12.0;

  final List<List<List<int>>> tetrominoes = [
    [[1, 1, 1, 1]], 
    [[1, 1], [1, 1]], 
    [[0, 1, 0], [1, 1, 1]], 
    [[1, 0], [1, 0], [1, 1]],
    [[0, 1], [0, 1], [1, 1]], 
    [[0, 1, 1], [1, 1, 0]], 
    [[1, 1, 0], [0, 1, 1]] 
  ];

  @override
  void initState() {
    super.initState();
    spawnNewBlock();
    fetchStatus();
    statusTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      fetchStatus();
    });
    gameTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (eyeClosed == true) moveDown();
    });
  }

  @override
  void dispose() {
    statusTimer?.cancel();
    gameTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchStatus() async {
    try {
      final res = await http.get(Uri.parse(serverUrl));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        bool? newStatus;
        if (data["status"] is bool) {
          newStatus = data["status"];
        } else {
          final statusString = data["status"].toString().toUpperCase().trim();
          newStatus = statusString.contains("CLOSED");
        }
        setState(() {
          eyeClosed = newStatus;
        });
      }
    } catch (e) {
      debugPrint("Error fetching status: $e");
    }
  }

  void moveDown() {
    debugPrint("moveDown()");
    if (!canMove(currentRow + 1, currentCol, currentShape)) {
      placeBlock();
      clearLines();
      spawnNewBlock();
      return;
    }
    setState(() {
      currentRow++;
    });
  }

  void moveLeft() {
    debugPrint("moveLeft()");
    if (canMove(currentRow, currentCol - 1, currentShape)) {
      setState(() {
        currentCol--;
      });
    }
  }

  void moveRight() {
    debugPrint("moveRight()");
    if (canMove(currentRow, currentCol + 1, currentShape)) {
      setState(() {
        currentCol++;
      });
    }
  }

  void rotate() {
    debugPrint("rotate()");
    final rotated = List.generate(
      currentShape[0].length,
      (c) => List.generate(
          currentShape.length, (r) => currentShape[currentShape.length - 1 - r][c]),
    );
    if (canMove(currentRow, currentCol, rotated)) {
      setState(() {
        currentShape = rotated;
      });
    }
  }

  bool canMove(int newRow, int newCol, List<List<int>> shape) {
    for (int r = 0; r < shape.length; r++) {
      for (int c = 0; c < shape[r].length; c++) {
        if (shape[r][c] == 1) {
          int gridRow = newRow + r;
          int gridCol = newCol + c;
          if (gridRow < 0 ||
              gridRow >= rows ||
              gridCol < 0 ||
              gridCol >= cols ||
              grid[gridRow][gridCol] != null) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void placeBlock() {
    for (int r = 0; r < currentShape.length; r++) {
      for (int c = 0; c < currentShape[r].length; c++) {
        if (currentShape[r][c] == 1) {
          grid[currentRow + r][currentCol + c] = currentColor;
        }
      }
    }
  }

  void clearLines() {
    for (int r = rows - 1; r >= 0; r--) {
      if (grid[r].every((cell) => cell != null)) {
        setState(() {
          grid.removeAt(r);
          grid.insert(0, List.generate(cols, (_) => null));
          score += 100;
        });
        r++; // re-check this row index after shifting
      }
    }
  }

  void spawnNewBlock() {
    final random = DateTime.now().millisecondsSinceEpoch;
    currentShape = tetrominoes[random % tetrominoes.length];
    currentColor = Colors.primaries[random % Colors.primaries.length].shade400;
    currentRow = 0;
    currentCol = (cols ~/ 2) - (currentShape[0].length ~/ 2);

    if (!canMove(currentRow, currentCol, currentShape)) {
      // Simple Game Over: reset board & score
      grid = List.generate(rows, (_) => List.generate(cols, (_) => null));
      score = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Score: $score",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (_) {
                  _panDxAccum = 0.0;
                  _panDyAccum = 0.0;
                  _dragMoved = false;
                },
                onPanUpdate: (details) {
                  _panDxAccum += details.delta.dx;
                  _panDyAccum += details.delta.dy;

                  if (!_dragMoved) {
                    if (_panDxAccum.abs() >= _dragThreshold) {
                      if (_panDxAccum < 0) {
                        moveLeft();
                      } else {
                        moveRight();
                      }
                      _dragMoved = true;
                    } else if (_panDyAccum.abs() >= _dragThreshold) {
                      if (_panDyAccum > 0) {
                        moveDown();
                        _dragMoved = true;
                      }
                    }
                  }
                },
                onPanEnd: (_) {
                  _panDxAccum = 0.0;
                  _panDyAccum = 0.0;
                  _dragMoved = false;
                },
                onTap: rotate,
                child: AspectRatio(
                  aspectRatio: cols / rows,
                  child: Column(
                    children: List.generate(rows, (r) {
                      return Expanded(
                        child: Row(
                          children: List.generate(cols, (c) {
                            Color? color = grid[r][c];
                            int shapeRow = r - currentRow;
                            int shapeCol = c - currentCol;
                            if (shapeRow >= 0 &&
                                shapeRow < currentShape.length &&
                                shapeCol >= 0 &&
                                shapeCol < currentShape[0].length &&
                                currentShape[shapeRow][shapeCol] == 1) {
                              color = currentColor;
                            }
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: color ?? Colors.grey[900],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

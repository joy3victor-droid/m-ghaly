
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MGhalyApp());
}

class MGhalyApp extends StatelessWidget {
  const MGhalyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'M-GHALY',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

bool isVideo(XFile file) {
  final path = file.path.toLowerCase();

  return path.endsWith('.mp4') ||
      path.endsWith('.mov') ||
      path.endsWith('.mkv') ||
      path.endsWith('.webm') ||
      path.endsWith('.3gp') ||
      path.endsWith('.avi');
}

// ================= HOME SCREEN =================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> openProject(BuildContext context) async {
    final picker = ImagePicker();
    final selectedFiles = await picker.pickMultipleMedia();

    if (!context.mounted || selectedFiles.isEmpty) return;

    final usedPaths = <String>{};

    final videos = selectedFiles
        .where(isVideo)
        .where((file) => usedPaths.add(file.path))
        .toList();

    if (videos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لم يتم اختيار أي فيديو'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectScreen(files: videos),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101116),
      appBar: AppBar(
        title: const Text('M-GHALY'),
        centerTitle: true,
        backgroundColor: const Color(0xFF191A22),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.video_library,
              size: 90,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              'M-GHALY VIDEO EDITOR',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => openProject(context),
              icon: const Icon(Icons.add),
              label: const Text('New Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= PROJECT SCREEN =================

class ProjectScreen extends StatefulWidget {
  final List<XFile> files;

  const ProjectScreen({
    super.key,
    required this.files,
  });

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  late List<XFile> files;

  VideoPlayerController? controller;

  int selectedIndex = 0;
  int loadRequestId = 0;

  bool videoReady = false;
  bool isAutoAdvancing = false;

  String? videoError;

  VideoPlayerController? lastCompletedController;

  final Map<String, Future<Uint8List?>> thumbnails = {};

  @override
  void initState() {
    super.initState();

    files = List<XFile>.of(widget.files);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (files.isNotEmpty) {
      loadVideo(0);
    }
  }

  // ================= THUMBNAILS =================

  Future<Uint8List?> getThumbnail(String path) {
    return thumbnails.putIfAbsent(
      path,
      () => VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 240,
        quality: 65,
      ),
    );
  }

  // ================= ADD VIDEOS =================

  Future<void> addVideos() async {
    final picker = ImagePicker();
    final selectedFiles = await picker.pickMultipleMedia();

    if (!mounted || selectedFiles.isEmpty) return;

    final existingPaths = files.map((file) => file.path).toSet();

    final newVideos = selectedFiles
        .where(isVideo)
        .where((file) => existingPaths.add(file.path))
        .toList();

    if (newVideos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لم تتم إضافة فيديوهات جديدة'),
        ),
      );
      return;
    }

    final wasEmpty = files.isEmpty;

    setState(() {
      files.addAll(newVideos);
    });

    if (wasEmpty) {
      await loadVideo(0);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة ${newVideos.length} فيديو'),
      ),
    );
  }

  // ================= LOAD VIDEO =================

  Future<void> loadVideo(
    int index, {
    bool autoplay = false,
  }) async {
    if (!mounted || index < 0 || index >= files.length) return;

    final targetFile = files[index];
    final requestId = ++loadRequestId;

    final oldController = controller;

    oldController?.removeListener(handleVideoProgress);

    setState(() {
      selectedIndex = index;
      videoReady = false;
      videoError = null;
      controller = null;
      lastCompletedController = null;
    });

    await oldController?.dispose();

    if (!mounted || requestId != loadRequestId) return;

    if (!files.any((file) => file.path == targetFile.path)) return;

    final newController = VideoPlayerController.file(
      File(targetFile.path),
    );

    controller = newController;

    try {
      await newController.initialize();

      if (!mounted ||
          requestId != loadRequestId ||
          controller != newController) {
        return;
      }

      final actualIndex = files.indexWhere(
        (file) => file.path == targetFile.path,
      );

      if (actualIndex == -1) return;

      newController.addListener(handleVideoProgress);

      setState(() {
        selectedIndex = actualIndex;
        videoReady = true;
      });

      if (autoplay) {
        await newController.play();
      }
    } catch (e) {
      if (!mounted ||
          requestId != loadRequestId ||
          controller != newController) {
        return;
      }

      setState(() {
        videoError = e.toString();
      });
    }
  }

  // ================= PLAY / PAUSE =================

  Future<void> togglePlayback(
    VideoPlayerController activeController,
  ) async {
    if (activeController.value.isPlaying) {
      await activeController.pause();
    } else {
      if (activeController.value.duration > Duration.zero &&
          activeController.value.position >=
              activeController.value.duration) {
        await activeController.seekTo(Duration.zero);
      }

      lastCompletedController = null;

      await activeController.play();
    }
  }

  // ================= AUTO NEXT VIDEO =================

  void handleVideoProgress() {
    final activeController = controller;

    if (!mounted || !videoReady || activeController == null) return;

    final value = activeController.value;

    if (!value.isInitialized ||
        value.isPlaying ||
        value.duration <= Duration.zero) {
      return;
    }

    if (value.position >= value.duration) {
      if (lastCompletedController == activeController ||
          isAutoAdvancing) {
        return;
      }

      lastCompletedController = activeController;

      unawaited(playNextVideo(activeController));
    }
  }

  Future<void> playNextVideo(
    VideoPlayerController endedController,
  ) async {
    if (isAutoAdvancing || controller != endedController) return;

    isAutoAdvancing = true;

    try {
      final nextIndex = selectedIndex + 1;

      if (nextIndex < files.length) {
        await loadVideo(
          nextIndex,
          autoplay: true,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('انتهى تشغيل جميع الفيديوهات'),
          ),
        );
      }
    } finally {
      isAutoAdvancing = false;
    }
  }

  // ================= DELETE VIDEO =================

  Future<void> confirmDeleteVideo(int index) async {
    if (index < 0 || index >= files.length) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF252630),
          title: const Text('حذف الفيديو'),
          content: const Text(
            'هل تريد حذف هذا الفيديو من المشروع؟',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'حذف',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    await deleteVideo(index);
  }

  Future<void> deleteVideo(int index) async {
    if (index < 0 || index >= files.length) return;

    final wasSelected = index == selectedIndex;
    final deletedPath = files[index].path;

    setState(() {
      files.removeAt(index);
      thumbnails.remove(deletedPath);

      if (files.isEmpty) {
        selectedIndex = 0;
      } else if (wasSelected) {
        selectedIndex = index >= files.length
            ? files.length - 1
            : index;
      } else if (index < selectedIndex) {
        selectedIndex--;
      }
    });

    if (wasSelected) {
      if (files.isEmpty) {
        await clearPreview();
      } else {
        await loadVideo(selectedIndex);
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف الفيديو من المشروع'),
      ),
    );
  }

  // ================= CLEAR PREVIEW =================

  Future<void> clearPreview() async {
    loadRequestId++;

    final oldController = controller;

    oldController?.removeListener(handleVideoProgress);

    setState(() {
      controller = null;
      videoReady = false;
      videoError = null;
      selectedIndex = 0;
      lastCompletedController = null;
    });

    await oldController?.dispose();
  }

  // ================= REORDER VIDEOS =================

  void reorderVideos(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    if (oldIndex < 0 ||
        oldIndex >= files.length ||
        newIndex < 0 ||
        newIndex >= files.length) {
      return;
    }

    final selectedPath = selectedIndex < files.length
        ? files[selectedIndex].path
        : null;

    setState(() {
      final movedFile = files.removeAt(oldIndex);

      files.insert(newIndex, movedFile);

      if (selectedPath != null) {
        selectedIndex = files.indexWhere(
          (file) => file.path == selectedPath,
        );
      }
    });
  }

  // ================= TIME FORMAT =================

  String formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // ================= DISPOSE =================

  @override
  void dispose() {
    loadRequestId++;

    controller?.removeListener(handleVideoProgress);
    controller?.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  // ================= USER INTERFACE =================

  @override
  Widget build(BuildContext context) {
    final currentController = controller;

    return Scaffold(
      backgroundColor: const Color(0xFF101116),

      appBar: AppBar(
        title: const Text('M-GHALY Editor'),
        backgroundColor: const Color(0xFF191A22),
        actions: [
          IconButton(
            tooltip: 'إضافة فيديو',
            onPressed: () {
              unawaited(addVideos());
            },
            icon: const Icon(
              Icons.add_circle,
              color: Colors.orange,
              size: 30,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              child: Text('إضافة فيديو'),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ===== VIDEO PREVIEW =====

          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: videoReady && currentController != null
                          ? AspectRatio(
                              aspectRatio:
                                  currentController.value.aspectRatio,
                              child: VideoPlayer(currentController),
                            )
                          : videoError != null
                              ? const Text('تعذر تشغيل الفيديو')
                              : files.isEmpty
                                  ? const Text('أضف فيديو لبدء المونتاج')
                                  : const CircularProgressIndicator(
                                      color: Colors.orange,
                                    ),
                    ),
                  ),
                ),

                // ===== PLAYER CONTROLS =====

                SizedBox(
                  width: 190,
                  child: Container(
                    color: const Color(0xFF191A22),
                    padding: const EdgeInsets.all(10),
                    child: videoReady && currentController != null
                        ? AnimatedBuilder(
                            animation: currentController,
                            builder: (context, child) {
                              final position =
                                  currentController.value.position;

                              final duration =
                                  currentController.value.duration;

                              final maxValue =
                                  duration.inMilliseconds > 0
                                      ? duration.inMilliseconds.toDouble()
                                      : 1.0;

                              final currentValue = position
                                  .inMilliseconds
                                  .toDouble()
                                  .clamp(0.0, maxValue)
                                  .toDouble();

                              return Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    iconSize: 48,
                                    color: Colors.orange,
                                    icon: Icon(
                                      currentController.value.isPlaying
                                          ? Icons.pause_circle
                                          : Icons.play_circle,
                                    ),
                                    onPressed: () {
                                      unawaited(
                                        togglePlayback(currentController),
                                      );
                                    },
                                  ),

                                  Slider(
                                    value: currentValue,
                                    min: 0,
                                    max: maxValue,
                                    activeColor: Colors.orange,
                                    onChanged: (value) {
                                      if (value < maxValue - 500) {
                                        lastCompletedController = null;
                                      }

                                      currentController.seekTo(
                                        Duration(
                                          milliseconds: value.toInt(),
                                        ),
                                      );
                                    },
                                  ),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatTime(position),
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      Text(
                                        formatTime(duration),
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          )
                        : const Center(
                            child: Text('معاينة الفيديو'),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // ===== TIMELINE TITLE =====

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 7),
            color: const Color(0xFF252630),
            child: Text(
              'TIMELINE  •  ${files.length} VIDEOS',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ===== TIMELINE =====

          SizedBox(
            height: 115,
            child: files.isEmpty
                ? const Center(
                    child: Text('لا توجد فيديوهات في المشروع'),
                  )
                : ReorderableListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    itemCount: files.length,
                    onReorderItem: reorderVideos,

                    // السحب يبدأ من البطاقة كلها بالضغط المطوّل
                    buildDefaultDragHandles: false,

                    itemBuilder: (context, index) {
                      final file = files[index];
                      final selected = selectedIndex == index;

                      return ReorderableDelayedDragStartListener(
                        key: ValueKey<String>(file.path),
                        index: index,
                        child: GestureDetector(
                          onTap: () {
                            unawaited(loadVideo(index));
                          },
                          child: Container(
                            width: 145,
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF252630),
                              border: Border.all(
                                color: selected
                                    ? Colors.orange
                                    : Colors.white24,
                                width: selected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      FutureBuilder<Uint8List?>(
                                        future: getThumbnail(file.path),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData &&
                                              snapshot.data != null) {
                                            return Image.memory(
                                              snapshot.data!,
                                              fit: BoxFit.cover,
                                            );
                                          }

                                          return const Center(
                                            child: Icon(
                                              Icons.video_file,
                                              color: Colors.orange,
                                              size: 30,
                                            ),
                                          );
                                        },
                                      ),

                                      // زر الحذف
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.black87,
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            tooltip: 'حذف الفيديو',
                                            iconSize: 18,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 30,
                                              minHeight: 30,
                                            ),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed: () {
                                              unawaited(
                                                confirmDeleteVideo(index),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // اسم الفيديو وعلامة السحب
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  color: selected
                                      ? const Color(0xFF49300F)
                                      : const Color(0xFF191A22),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Video ${index + 1}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 5,
                                        ),
                                        child: Icon(
                                          Icons.drag_indicator,
                                          color: Colors.orange,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

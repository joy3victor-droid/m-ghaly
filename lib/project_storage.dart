import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SavedProject {
  const SavedProject({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.videoPaths,
    required this.audioTracks,
    required this.textClips,
    required this.selectedIndex,
    required this.timelineScale,
    required this.videoPositionMs,
  });

  final String id;
  final String name;
  final DateTime updatedAt;
  final List<String> videoPaths;
  final List<Map<String, dynamic>> audioTracks;
  final List<Map<String, dynamic>> textClips;
  final int selectedIndex;
  final double timelineScale;
  final int videoPositionMs;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'updatedAt': updatedAt.toIso8601String(),
    'videoPaths': videoPaths,
    'audioTracks': audioTracks,
    'textClips': textClips,
    'selectedIndex': selectedIndex,
    'timelineScale': timelineScale,
    'videoPositionMs': videoPositionMs,
  };

  factory SavedProject.fromJson(Map<String, dynamic> json) {
    return SavedProject(
      id: json['id'] as String,
      name: json['name'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      videoPaths: List<String>.from(json['videoPaths'] as List),
      audioTracks: List<Map<String, dynamic>>.from(
        (json['audioTracks'] as List).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      ),
      textClips: List<Map<String, dynamic>>.from(
        (json['textClips'] as List).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      ),
      selectedIndex: json['selectedIndex'] as int? ?? 0,
      timelineScale: (json['timelineScale'] as num?)?.toDouble() ?? 1.0,
      videoPositionMs: json['videoPositionMs'] as int? ?? 0,
    );
  }
}

class ProjectStorage {
  static Future<Directory> get _root async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(appDirectory.path, 'ghaly_projects'));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  static Future<Directory> _projectDirectory(String id) async {
    final directory = Directory(p.join((await _root).path, id));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  static Future<String> copyMedia({
    required String projectId,
    required String sourcePath,
    required String category,
    required int index,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw FileSystemException('ملف الوسائط غير موجود', sourcePath);
    }

    final directory = Directory(
      p.join((await _projectDirectory(projectId)).path, category),
    );
    await directory.create(recursive: true);

    final extension = p.extension(sourcePath);
    final fileName =
        '${index}_${DateTime.now().microsecondsSinceEpoch}$extension';
    final destination = p.join(directory.path, fileName);

    await source.copy(destination);
    return destination;
  }

  static Future<void> save(SavedProject project) async {
    final directory = await _projectDirectory(project.id);
    final file = File(p.join(directory.path, 'project.json'));
    final temporaryFile = File('${file.path}.tmp');

    await temporaryFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(project.toJson()),
      flush: true,
    );

    if (await file.exists()) {
      await file.delete();
    }
    await temporaryFile.rename(file.path);
  }

  static Future<List<SavedProject>> listProjects() async {
    final root = await _root;
    final projects = <SavedProject>[];

    await for (final entity in root.list()) {
      if (entity is! Directory) continue;

      final file = File(p.join(entity.path, 'project.json'));
      if (!await file.exists()) continue;

      try {
        final json = jsonDecode(await file.readAsString());
        projects.add(
          SavedProject.fromJson(Map<String, dynamic>.from(json as Map)),
        );
      } catch (_) {
        // تجاهل ملفات المشاريع التالفة مع الاحتفاظ بباقي المشاريع.
      }
    }

    projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return projects;
  }

  static Future<SavedProject?> load(String id) async {
    final file = File(
      p.join((await _projectDirectory(id)).path, 'project.json'),
    );
    if (!await file.exists()) return null;

    final json = jsonDecode(await file.readAsString());
    return SavedProject.fromJson(Map<String, dynamic>.from(json as Map));
  }

  static Future<void> delete(String id) async {
    final root = await _root;
    final projectPath = p.join(root.path, id);

    if (!p.isWithin(root.path, projectPath)) {
      throw ArgumentError('معرّف المشروع غير صالح');
    }

    final directory = Directory(projectPath);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}

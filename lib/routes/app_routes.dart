import 'package:flutter/material.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/export_and_share/export_and_share.dart';
import '../presentation/ai_mindmap_creation/ai_mindmap_creation.dart';
import '../presentation/mindmap_library/mindmap_library.dart';

class AppRoutes {
  // Route constants
  static const String initial = '/';
  static const String home = '/home';
  static const String exportAndShare = '/export-and-share';
  static const String aiMindmapCreation = '/ai-mindmap-creation';
  static const String mindmapLibrary = '/mindmap-library';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const HomeScreen(),
    home: (context) => const HomeScreen(),
    exportAndShare: (context) => const ExportAndShare(),
    aiMindmapCreation: (context) => const AiMindmapCreation(),
    mindmapLibrary: (context) => const MindmapLibrary(),
  };
}

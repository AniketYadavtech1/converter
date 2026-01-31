import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'All Document Reader';

  // Storage paths
  static const List<String> searchPaths = [
    '/storage/emulated/0/Download',
    '/storage/emulated/0/Documents',
    '/storage/emulated/0/DCIM',
    '/storage/emulated/0/Pictures',
    '/storage/emulated/0/WhatsApp',
    '/storage/emulated/0',
  ];

  // Skip patterns
  static const List<String> skipPatterns = [
    '/Android/data',
    '/Android/obb',
    '/.',
    '/cache',
    '/thumbnails',
  ];

  // File types
  static const Map<String, FileTypeConfig> fileTypes = {
    'pdf': FileTypeConfig(
      name: 'PDF',
      icon: Icons.picture_as_pdf,
      color: Colors.red,
      extensions: ['.pdf'],
    ),
    'word': FileTypeConfig(
      name: 'Word',
      icon: Icons.description,
      color: Colors.blue,
      extensions: ['.doc', '.docx'],
    ),
    'excel': FileTypeConfig(
      name: 'Excel',
      icon: Icons.table_chart,
      color: Colors.green,
      extensions: ['.xls', '.xlsx'],
    ),
    'ppt': FileTypeConfig(
      name: 'PowerPoint',
      icon: Icons.slideshow,
      color: Colors.orange,
      extensions: ['.ppt', '.pptx'],
    ),
    'txt': FileTypeConfig(
      name: 'Text',
      icon: Icons.text_snippet,
      color: Colors.grey,
      extensions: ['.txt'],
    ),
    'image': FileTypeConfig(
      name: 'Images',
      icon: Icons.image,
      color: Colors.amber,
      extensions: ['.jpg', '.jpeg', '.png', '.gif', '.webp'],
    ),
    'all': FileTypeConfig(
      name: 'All Files',
      icon: Icons.folder,
      color: Colors.cyan,
      extensions: [],
    ),
  };
}

class FileTypeConfig {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> extensions;

  const FileTypeConfig({
    required this.name,
    required this.icon,
    required this.color,
    required this.extensions,
  });
}
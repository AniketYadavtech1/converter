import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

class FileUtils {
  static IconData getFileIcon(String path) {
    final lowerPath = path.toLowerCase();

    for (var entry in AppConstants.fileTypes.entries) {
      if (entry.value.extensions.any((ext) => lowerPath.endsWith(ext))) {
        return entry.value.icon;
      }
    }
    return Icons.insert_drive_file;
  }

  static Color getFileColor(String path) {
    final lowerPath = path.toLowerCase();

    for (var entry in AppConstants.fileTypes.entries) {
      if (entry.value.extensions.any((ext) => lowerPath.endsWith(ext))) {
        return entry.value.color;
      }
    }
    return Colors.cyan;
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }
}
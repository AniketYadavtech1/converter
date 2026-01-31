import 'package:converter/view/newreader/ui/file_list_screen.dart';
import 'package:converter/view/utill/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FileTypeCard extends StatelessWidget {
  final String type;

  const FileTypeCard({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final config = AppConstants.fileTypes[type]!;

    return InkWell(
      onTap: () => Get.to(() => FileListScreen(fileType: type)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              config.color.withOpacity(0.8),
              config.color,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: config.color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                config.icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              config.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
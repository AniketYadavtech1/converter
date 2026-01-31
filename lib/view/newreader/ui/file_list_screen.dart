import 'package:converter/view/newreader/component/file_item_card.dart';
import 'package:converter/view/newreader/controller/file_list_controller.dart';
import 'package:converter/view/utill/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FileListScreen extends StatelessWidget {
  final String fileType;

  const FileListScreen({super.key, required this.fileType});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      FileListController(fileType),
      tag: fileType,
    );

    final config = AppConstants.fileTypes[fileType]!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          '${config.name} Files',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [config.color, config.color.withOpacity(0.7)],
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => controller.changeSortBy(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 20),
                    SizedBox(width: 8),
                    Text('Sort by Date'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 20),
                    SizedBox(width: 8),
                    Text('Sort by Name'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'size',
                child: Row(
                  children: [
                    Icon(Icons.data_usage, size: 20),
                    SizedBox(width: 8),
                    Text('Sort by Size'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadFiles(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: config.color),
                const SizedBox(height: 16),
                const Text(
                  'Scanning files...',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade300,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => controller.loadFiles(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: config.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.files.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${config.name} files found',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // File Count Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: config.color.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: config.color.withOpacity(0.2)),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder, size: 20, color: config.color),
                  const SizedBox(width: 8),
                  Text(
                    '${controller.files.length} file${controller.files.length == 1 ? '' : 's'} found',
                    style: TextStyle(
                      color: config.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Obx(() => Text(
                    'Sorted by ${controller.sortBy.value}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  )),
                ],
              ),
            ),

            // Files List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                itemCount: controller.files.length,
                itemBuilder: (context, index) {
                  final fileInfo = controller.files[index];
                  return FileItemCard(
                    fileInfo: fileInfo,
                    onTap: () => controller.openFile(fileInfo),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
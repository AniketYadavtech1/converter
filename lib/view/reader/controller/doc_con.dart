import 'dart:io';

import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

class DocController extends GetxController {

  RxList<File> docFiles = <File>[].obs;
  RxBool isLoading = false.obs;

  // Pick Folder + Scan
  Future<void> scanDocuments() async {

    String? folderPath =
    await FilePicker.platform.getDirectoryPath();

    if (folderPath == null) {
      Get.snackbar("Folder", "No folder selected");
      return;
    }

    await scanFolder(folderPath);
  }

  // Scan Folder
  Future<void> scanFolder(String path) async {

    isLoading.value = true;
    docFiles.clear();

    final dir = Directory(path);

    if (!await dir.exists()) {
      isLoading.value = false;
      return;
    }

    await for (var entity
    in dir.list(recursive: true, followLinks: false)) {

      if (entity is File) {

        final filePath = entity.path.toLowerCase();

        if (filePath.endsWith('.doc') ||
            filePath.endsWith('.docx')) {

          docFiles.add(entity);
        }
      }
    }

    isLoading.value = false;
  }
}

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

/// ================= CONTROLLER =================
class CsvController extends GetxController {
  Rx<File?> selectedCsv = Rx<File?>(null);
  Rx<File?> compressedCsv = Rx<File?>(null);
  RxString preview = "".obs;
  RxBool isLoading = false.obs;

  /// 🔹 Pick CSV
  Future<void> pickCsv() async {
    try {
      /// Android Download path
      String downloadPath = "/storage/emulated/0/Download";

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        initialDirectory: downloadPath, // 👈 Open Download section
      );

      if (result != null) {
        selectedCsv.value = File(result.files.single.path!);
        readPreview();
      } else {
        Get.snackbar("Cancelled", "No file selected");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }


  /// 🔹 Preview CSV
  Future<void> readPreview() async {
    if (selectedCsv.value == null) return;

    isLoading.value = true;

    String content = await selectedCsv.value!.readAsString();
    List<String> lines = content.split('\n');

    preview.value = lines.take(10).join('\n');

    isLoading.value = false;
  }

  /// ================= COMPRESS FUNCTION =================
  Future<void> compressCsv() async {
    if (selectedCsv.value == null) {
      Get.snackbar("Error", "Pick CSV first");
      return;
    }

    isLoading.value = true;

    String content = await selectedCsv.value!.readAsString();

    /// Remove empty + trim spaces
    List<String> lines = content.split('\n');

    List<String> optimized = lines
        .where((e) => e.trim().isNotEmpty)
        .map((e) => e.split(',').map((c) => c.trim()).join(','))
        .toList();

    String compressedData = optimized.join('\n');

    /// Save temp compressed file
    Directory tempDir = Directory.systemTemp;
    File file = File(
        "${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.csv");

    await file.writeAsString(compressedData);

    compressedCsv.value = file;

    isLoading.value = false;

    Get.snackbar("Success", "CSV Compressed");
  }

  /// ================= SAVE FUNCTION =================
  Future<void> saveToDownload() async {
    if (compressedCsv.value == null) {
      Get.snackbar("Error", "Compress file first");
      return;
    }

    /// Permission
    PermissionStatus status = await Permission.storage.request();

    if (!status.isGranted) {
      Get.snackbar("Permission", "Storage permission required");
      return;
    }

    try {
      /// Android Download path
      String downloadPath = "/storage/emulated/0/Download";

      File newFile = File(
          "$downloadPath/compressed_${DateTime.now().millisecondsSinceEpoch}.csv");

      await compressedCsv.value!.copy(newFile.path);

      Get.snackbar("Saved", "File saved in Download folder");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}

/// ================= UI =================
class CsvScreen extends StatelessWidget {
  CsvScreen({super.key});

  final CsvController controller = Get.put(CsvController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CSV Compress & Save")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: controller.pickCsv,
              child: const Text("Pick CSV"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: controller.compressCsv,
              child: const Text("Compress CSV"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: controller.saveToDownload,
              child: const Text("Save to Download"),
            ),

            const SizedBox(height: 20),

            /// Loading
            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator()
                : const SizedBox()),

            const SizedBox(height: 20),

            /// Preview
            Obx(() => Expanded(
              child: SingleChildScrollView(
                child: Text(
                  controller.preview.value.isEmpty
                      ? "CSV Preview"
                      : controller.preview.value,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

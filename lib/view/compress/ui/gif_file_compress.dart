import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/animation.dart' as img;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class GifController extends GetxController {

  Rx<File?> originalGif = Rx<File?>(null);
  Rx<File?> compressedGif = Rx<File?>(null);

  RxBool isLoading = false.obs;
  RxString originalSize = ''.obs;
  RxString compressedSize = ''.obs;

  final ImagePicker _picker = ImagePicker();

  /// PICK GIF
  Future<void> pickGif() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gif'],
      );

      if (result == null) return;

      File file = File(result.files.single.path!);

      originalGif.value = file;
      originalSize.value = await _getFileSize(file);

    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
  /// COMPRESS GIF
  Future<void> compressGif() async {
    if (originalGif.value == null) return;

    isLoading.value = true;

    try {
      Uint8List bytes = await originalGif.value!.readAsBytes();

      final decoder = img.GifDecoder();
      final animation = decoder.decode(bytes);

      if (animation == null || animation.frames.isEmpty) {
        Get.snackbar("Error", "Invalid GIF");
        isLoading.value = false;
        return;
      }

      final encoder = img.GifEncoder()
        ..repeat = 0; // infinite loop

      for (final frame in animation.frames) {
        img.Image resized = img.copyResize(
          frame,
          width: (frame.width * 0.7).toInt(),
        );

        int duration = frame.frameDuration;
        if (duration <= 0) duration = 100;

        encoder.addFrame(resized, duration: duration);
      }

      final compressedBytes = encoder.finish();

      if (compressedBytes == null) {
        Get.snackbar("Error", "Compression failed");
        isLoading.value = false;
        return;
      }

      Directory dir = await getApplicationDocumentsDirectory();
      File file = File(
          "${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.gif");

      await file.writeAsBytes(compressedBytes);

      compressedGif.value = file;
      compressedSize.value = await _getFileSize(file);

      Get.snackbar("Success", "GIF Compressed Successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }

    isLoading.value = false;
  }









  /// SAVE TO DOWNLOADS
  Future<void> saveToDownloads() async {
    if (compressedGif.value == null) return;

    await Permission.storage.request();

    Directory? downloadsDir =
    Directory('/storage/emulated/0/Download');

    File newFile = File(
        "${downloadsDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.gif");

    await newFile.writeAsBytes(
        await compressedGif.value!.readAsBytes());

    Get.snackbar("Saved", "GIF saved in Downloads folder");
  }

  /// GET FILE SIZE
  Future<String> _getFileSize(File file) async {
    int bytes = await file.length();
    double kb = bytes / 1024;
    double mb = kb / 1024;

    if (mb >= 1) {
      return "${mb.toStringAsFixed(2)} MB";
    } else {
      return "${kb.toStringAsFixed(2)} KB";
    }
  }
}





class GifScreen extends StatelessWidget {
  final GifController controller = Get.put(GifController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GIF Compressor")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() => Column(
          children: [

            /// PICK BUTTON
            ElevatedButton(
              onPressed: controller.pickGif,
              child: Text("Pick GIF"),
            ),

            SizedBox(height: 20),

            /// PREVIEW ORIGINAL
            if (controller.originalGif.value != null)
              Column(
                children: [
                  Text("Original: ${controller.originalSize.value}"),
                  SizedBox(height: 10),
                  Image.file(
                    controller.originalGif.value!,
                    height: 150,
                  ),
                ],
              ),

            SizedBox(height: 20),

            /// COMPRESS BUTTON
            ElevatedButton(
              onPressed: controller.compressGif,
              child: Text("Compress GIF"),
            ),

            SizedBox(height: 20),

            if (controller.isLoading.value)
              CircularProgressIndicator(),

            /// PREVIEW COMPRESSED
            if (controller.compressedGif.value != null)
              Column(
                children: [
                  Text("Compressed: ${controller.compressedSize.value}"),
                  SizedBox(height: 10),
                  Image.file(
                    controller.compressedGif.value!,
                    height: 150,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: controller.saveToDownloads,
                    child: Text("Download GIF"),
                  )
                ],
              ),
          ],
        )),
      ),
    );
  }
}









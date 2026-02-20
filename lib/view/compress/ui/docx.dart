// import 'dart:io';
// import 'package:archive/archive.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image/image.dart' as img;
// import 'package:path_provider/path_provider.dart';
//
// class DocxController extends GetxController {
//   Rx<File?> originalFile = Rx<File?>(null);
//   Rx<File?> compressedFile = Rx<File?>(null);
//
//   RxString originalSize = ''.obs;
//   RxString compressedSize = ''.obs;
//   RxBool isLoading = false.obs;
//
//   /// Pick DOCX
//   Future<void> pickDocx() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['docx'],
//     );
//
//     if (result == null) return;
//
//     File file = File(result.files.single.path!);
//     originalFile.value = file;
//     originalSize.value = await _getFileSize(file);
//   }
//
//   /// REAL DOCX COMPRESSION
//   Future<void> compressDocx() async {
//     if (originalFile.value == null) return;
//
//     try {
//       isLoading.value = true;
//
//       final bytes = await originalFile.value!.readAsBytes();
//
//       Archive archive = ZipDecoder().decodeBytes(bytes);
//
//       Archive newArchive = Archive();
//
//       for (ArchiveFile file in archive) {
//         if (file.isFile && file.name.startsWith('word/media/')) {
//           // 👇 Compress Images inside DOCX
//           if (file.name.endsWith('.png') ||
//               file.name.endsWith('.jpg') ||
//               file.name.endsWith('.jpeg')) {
//             img.Image? image =
//             img.decodeImage(file.content);
//
//             if (image != null) {
//               img.Image resized = img.copyResize(
//                 image,
//                 width: (image.width * 0.6).toInt(),
//               );
//
//               List<int> compressedImage;
//
//               if (file.name.endsWith('.png')) {
//                 compressedImage = img.encodePng(resized, level: 9);
//               } else {
//                 compressedImage =
//                     img.encodeJpg(resized, quality: 60);
//               }
//
//               newArchive.addFile(
//                 ArchiveFile(
//                   file.name,
//                   compressedImage.length,
//                   compressedImage,
//                 ),
//               );
//             }
//           } else {
//             newArchive.addFile(file);
//           }
//         } else {
//           newArchive.addFile(file);
//         }
//       }
//
//       // 🔥 Re-zip DOCX
//       final compressedData =
//       ZipEncoder().encode(newArchive, level: 9);
//
//       final dir = await getTemporaryDirectory();
//       final outputFile = File(
//           "${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.docx");
//
//       await outputFile.writeAsBytes(compressedData!);
//
//       compressedFile.value = outputFile;
//       compressedSize.value = await _getFileSize(outputFile);
//
//       Get.snackbar("Success", "DOCX Compressed Successfully");
//     } catch (e) {
//       Get.snackbar("Error", e.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<String> _getFileSize(File file) async {
//     int bytes = await file.length();
//     double kb = bytes / 1024;
//     double mb = kb / 1024;
//
//     if (mb >= 1) {
//       return "${mb.toStringAsFixed(2)} MB";
//     } else {
//       return "${kb.toStringAsFixed(2)} KB";
//     }
//   }
//
//
//   Future<void> saveToDownloads() async {
//     if (compressedFile.value == null) return;
//
//     final downloadsDir = Directory('/storage/emulated/0/Download');
//
//     final newFile = File(
//         "${downloadsDir.path}/${compressedFile.value!.path.split('/').last}");
//
//     await newFile.writeAsBytes(
//         await compressedFile.value!.readAsBytes());
//
//     Get.snackbar("Saved", "File saved to Downloads");
//   }
// }
//
//
//
// class DocxCompressionScreen extends StatelessWidget {
//   DocxCompressionScreen({super.key});
//
//   final controller = Get.put(DocxController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("DOCX Compressor"),
//         centerTitle: true,
//       ),
//       body: Obx(() => Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//
//             /// Pick Button
//             ElevatedButton(
//               onPressed: controller.pickDocx,
//               child: const Text("Pick DOCX File"),
//             ),
//
//             const SizedBox(height: 20),
//
//             /// Original Info
//             if (controller.originalFile.value != null) ...[
//               const Text(
//                 "Original File",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 5),
//               Text(
//                 controller.originalFile.value!.path.split('/').last,
//               ),
//               Text("Size: ${controller.originalSize.value}"),
//               const SizedBox(height: 20),
//             ],
//
//             /// Compress Button
//             if (controller.originalFile.value != null)
//               ElevatedButton(
//                 onPressed: controller.compressDocx,
//                 child: const Text("Compress File"),
//               ),
//
//             const SizedBox(height: 20),
//
//             /// Loading
//             if (controller.isLoading.value)
//               const Center(child: CircularProgressIndicator()),
//
//             const SizedBox(height: 20),
//
//             /// Compressed Info
//             if (controller.compressedFile.value != null) ...[
//               const Divider(),
//               const Text(
//                 "Compressed File",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 5),
//               Text(
//                 controller.compressedFile.value!.path.split('/').last,
//               ),
//               Text("Size: ${controller.compressedSize.value}"),
//               const SizedBox(height: 20),
//
//               ElevatedButton(
//                 onPressed: () async {
//                   await controller.saveToDownloads();
//                 },
//                 child: const Text("Save to Downloads"),
//               ),
//             ],
//           ],
//         ),
//       )),
//     );
//   }
// }

import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class DocxController extends GetxController {
  Rx<File?> originalFile = Rx<File?>(null);
  Rx<File?> compressedFile = Rx<File?>(null);

  RxString originalSize = ''.obs;
  RxString compressedSize = ''.obs;
  RxBool isLoading = false.obs;

  /// PICK DOCX
  Future<void> pickDocx() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['docx']);

    if (result == null) return;

    File file = File(result.files.single.path!);
    originalFile.value = file;
    originalSize.value = await _getFileSize(file);
    compressedFile.value = null;
  }

  /// COMPRESS DOCX
  Future<void> compressDocx() async {
    if (originalFile.value == null) return;

    try {
      isLoading.value = true;

      final bytes = await originalFile.value!.readAsBytes();
      Archive archive = ZipDecoder().decodeBytes(bytes);
      Archive newArchive = Archive();

      for (ArchiveFile file in archive) {
        if (file.isFile && file.name.startsWith('word/media/')) {
          if (file.name.endsWith('.png') || file.name.endsWith('.jpg') || file.name.endsWith('.jpeg')) {
            img.Image? image = img.decodeImage(file.content);

            if (image != null) {
              img.Image resized = img.copyResize(image, width: (image.width * 0.6).toInt());

              List<int> compressedImage;

              if (file.name.endsWith('.png')) {
                compressedImage = img.encodePng(resized, level: 9);
              } else {
                compressedImage = img.encodeJpg(resized, quality: 60);
              }

              newArchive.addFile(ArchiveFile(file.name, compressedImage.length, compressedImage));
            }
          } else {
            newArchive.addFile(file);
          }
        } else {
          newArchive.addFile(file);
        }
      }

      final compressedData = ZipEncoder().encode(newArchive, level: 9);

      final dir = await getTemporaryDirectory();
      final outputFile = File("${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.docx");

      await outputFile.writeAsBytes(compressedData!);

      compressedFile.value = outputFile;
      compressedSize.value = await _getFileSize(outputFile);

      Get.snackbar("Success", "DOCX Compressed Successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// SAVE TO DOWNLOADS
  Future<void> saveToDownloads() async {
    if (compressedFile.value == null) return;

    await Permission.storage.request();

    final downloadsDir = Directory('/storage/emulated/0/Download');

    final newFile = File("${downloadsDir.path}/${compressedFile.value!.path.split('/').last}");

    await newFile.writeAsBytes(await compressedFile.value!.readAsBytes());

    Get.snackbar("Saved", "File saved to Downloads");
  }

  /// FILE SIZE
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

  /// % SAVED
  double calculateSavedPercentage() {
    if (originalFile.value == null || compressedFile.value == null) return 0;

    final originalBytes = originalFile.value!.lengthSync();
    final compressedBytes = compressedFile.value!.lengthSync();

    double saved = ((originalBytes - compressedBytes) / originalBytes) * 100;

    return saved.isNegative ? 0 : double.parse(saved.toStringAsFixed(1));
  }
}

class DocxCompressionScreen extends StatelessWidget {
  DocxCompressionScreen({super.key});

  final controller = Get.put(DocxController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DOCX Compressor"), centerTitle: true),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ElevatedButton(onPressed: controller.pickDocx, child: const Text("Pick DOCX File")),

              const SizedBox(height: 20),

              if (controller.originalFile.value != null)
                _infoCard(
                  "Original File",
                  controller.originalFile.value!.path.split('/').last,
                  controller.originalSize.value,
                  Colors.blue,
                ),

              const SizedBox(height: 20),

              if (controller.originalFile.value != null)
                ElevatedButton(onPressed: controller.compressDocx, child: const Text("Compress File")),

              const SizedBox(height: 20),

              if (controller.isLoading.value) const CircularProgressIndicator(),

              const SizedBox(height: 20),

              if (controller.compressedFile.value != null)
                _infoCard(
                  "Compressed File",
                  controller.compressedFile.value!.path.split('/').last,
                  controller.compressedSize.value,
                  Colors.green,
                ),

              const SizedBox(height: 10),

              if (controller.compressedFile.value != null)
                Text(
                  "You saved ${controller.calculateSavedPercentage()} %",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),

              const SizedBox(height: 20),

              if (controller.compressedFile.value != null)
                ElevatedButton(onPressed: controller.saveToDownloads, child: const Text("Download Compressed File")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String fileName, String size, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
            ),
            const SizedBox(height: 8),
            Text("Name: $fileName"),
            Text("Size: $size"),
          ],
        ),
      ),
    );
  }
}

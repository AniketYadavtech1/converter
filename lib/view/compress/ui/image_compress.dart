import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart';

class ImageCompressController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  Rx<File?> originalImage = Rx<File?>(null);
  Rx<File?> compressedImage = Rx<File?>(null);

  RxDouble originalSize = 0.0.obs;
  RxDouble compressedSize = 0.0.obs;
  RxDouble savedPercentage = 0.0.obs;

  RxBool isLoading = false.obs;

  // String formatFileSize(double bytes) {
  //   if (bytes >= 1024 * 1024) {
  //     return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
  //   } else if (bytes >= 1024) {
  //     return "${(bytes / 1024).toStringAsFixed(2)} KB";
  //   } else {
  //     return "${bytes.toStringAsFixed(0)} B";
  //   }
  // }
  //
  // String formatFileSize(double bytes) {
  //   if (bytes >= 1000 * 1000) {
  //     return "${(bytes / (1000 * 1000)).toStringAsFixed(2)} MB";
  //   } else if (bytes >= 1000) {
  //     return "${(bytes / 1000).toStringAsFixed(2)} KB";
  //   } else {
  //     return "${bytes.toStringAsFixed(0)} B";
  //   }
  // }

  String formatFileSize(double bytes) {
    if (bytes <= 0) return "0 KB";

    // Use 1000 base (like mobile file managers)
    const int kb = 1000;
    const int mb = 1000 * 1000;

    if (bytes >= mb) {
      double value = bytes / mb;
      return "${value.toStringAsFixed(2)} MB";
    } else {
      double value = bytes / kb;
      return "${value.round()} KB";
    }
  }

  ///  Pick Image
  Future<void> pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      originalImage.value = File(picked.path);
      compressedImage.value = null;

      originalSize.value = await originalImage.value!.length() / 1024;
    }
  }

  /// 🔵 Compress Image
  Future<void> compressImage() async {
    if (originalImage.value == null) return;

    isLoading.value = true;

    final dir = await getTemporaryDirectory();
    final targetPath = "${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(originalImage.value!.path, targetPath, quality: 60);

    if (result != null) {
      compressedImage.value = File(result.path);

      /// 🔥 FIXED SIZE CALCULATION
      final int originalBytes = await originalImage.value!.length();

      final int compressedBytes = await compressedImage.value!.length();

      originalSize.value = originalBytes.toDouble();
      compressedSize.value = compressedBytes.toDouble();

      savedPercentage.value = originalSize.value == 0
          ? 0
          : ((originalSize.value - compressedSize.value) / originalSize.value) * 100;
    }

    isLoading.value = false;
  }

  /// 🔵 Download (Save to Storage)
  Future<void> downloadImage() async {
    if (compressedImage.value == null) return;

    final directory = Directory("/storage/emulated/0/Download");

    if (!await directory.exists()) {
      directory.createSync(recursive: true);
    }

    final newPath = "${directory.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

    await compressedImage.value!.copy(newPath);

    Get.snackbar("Success", "Image Saved to Download Folder");
  }
}

class ImageCompressScreen extends StatelessWidget {
  final controller = Get.put(ImageCompressController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Compressor")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Obx(
          () => SingleChildScrollView(
            child: Column(
              children: [
                /// 🔵 Select Button
                ElevatedButton(onPressed: controller.pickImage, child: Text("Select Image")),

                SizedBox(height: 15),

                /// 🔵 Preview Original
                if (controller.originalImage.value != null)
                  Column(
                    children: [
                      Text("Original Image"),
                      SizedBox(height: 8),
                      Image.file(controller.originalImage.value!, height: 150),
                    ],
                  ),

                SizedBox(height: 15),

                /// 🔵 Compress Button
                if (controller.originalImage.value != null && controller.compressedImage.value == null)
                  ElevatedButton(onPressed: controller.compressImage, child: Text("Compress Image")),

                SizedBox(height: 20),

                if (controller.isLoading.value) CircularProgressIndicator(),

                SizedBox(height: 20),

                /// 🔥 Result UI (iLoveIMG Style)
                if (controller.compressedImage.value != null)
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        /// 🔵 Circular Percentage
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 90,
                              width: 90,
                              child: CircularProgressIndicator(value: controller.savedPercentage.value / 100, strokeWidth: 8),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${controller.savedPercentage.value.toStringAsFixed(0)}%",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Text("SAVED", style: TextStyle(fontSize: 10)),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(width: 20),

                        /// 🔵 Text Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Images are now ${controller.savedPercentage.value.toStringAsFixed(0)}% smaller!",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 6),
                              // Text(
                              //   "${controller.formatFileSize(controller.originalSize.value)} → ${controller.formatFileSize(controller.compressedSize.value)}",
                              //   style: TextStyle(fontWeight: FontWeight.bold),
                              // ),
                              Text(
                                "${controller.formatFileSize(controller.originalSize.value)} → ${controller.formatFileSize(controller.compressedSize.value)}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 20),

                /// 🔵 Compressed Preview
                if (controller.compressedImage.value != null)
                  Column(
                    children: [
                      Text("Compressed Image"),
                      SizedBox(height: 8),
                      Image.file(controller.compressedImage.value!, height: 150),
                    ],
                  ),

                SizedBox(height: 20),

                /// 🔵 Download Button
                if (controller.compressedImage.value != null)
                  ElevatedButton.icon(
                    onPressed: controller.downloadImage,
                    icon: Icon(Icons.download),
                    label: Text("Download Image"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//
// Future<void> compressImage() async {
//   if (originalImage.value == null) return;
//
//   isLoading.value = true;
//
//   final dir = await getTemporaryDirectory();
//   final targetPath =
//       "${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";
//
//   final result = await FlutterImageCompress.compressAndGetFile(
//     originalImage.value!.path,
//     targetPath,
//     quality: 60,
//     keepExif: false, // remove metadata
//   );
//
//   if (result != null) {
//     final File compressedFile = File(result.path);
//
//     final int originalBytes = await originalImage.value!.length();
//     final int compressedBytes = await compressedFile.length();
//
//     originalSize.value = originalBytes.toDouble();
//
//     // ✅ IMPORTANT CHECK
//     if (compressedBytes < originalBytes) {
//       // Use compressed only if smaller
//       compressedImage.value = compressedFile;
//       compressedSize.value = compressedBytes.toDouble();
//
//       savedPercentage.value =
//           ((originalBytes - compressedBytes) / originalBytes) * 100;
//     } else {
//       // ❌ If compression increases size
//       compressedImage.value = originalImage.value;
//       compressedSize.value = originalBytes.toDouble();
//       savedPercentage.value = 0;
//     }
//   }
//
//   isLoading.value = false;
// }

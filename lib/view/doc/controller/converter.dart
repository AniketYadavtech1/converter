import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;

import '../model/convert_mode.ldart.dart';

class ConverterController extends GetxController {
  final Dio dio = Dio();

  // Converted PDF list
  RxList<ConvertedFile> convertedFiles = <ConvertedFile>[].obs;

  // Upload progress
  RxDouble uploadProgress = 0.0.obs;

  // Backend URL
  final String baseUrl = "http://10.194.253.136:3000";

  // ---------------- CONVERT DOCX → PDF ----------------
  Future<void> convertDoc(File file) async {
    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path),
      });

      final res = await dio.post(
        "$baseUrl/api/convert",
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            uploadProgress.value = sent / total;
          }
        },
      );

      // ✅ ADD CONVERTED FILE
      convertedFiles.add(
        ConvertedFile(
          name: "Converted PDF",
          type: "pdf",
          url: res.data["fileUrl"],
        ),
      );

      uploadProgress.value = 0;
    } catch (e) {
      uploadProgress.value = 0;
      Get.snackbar("Error", "Conversion failed");
      print("Convert error: $e");
    }
  }
}

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/converter.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ConverterController con =
  Get.put<ConverterController>(ConverterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DOC → PDF Converter")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔄 Upload progress
            Obx(() => LinearProgressIndicator(
              value: con.uploadProgress.value == 0
                  ? null
                  : con.uploadProgress.value,
            )),

            const SizedBox(height: 20),

            // 📂 Pick file
            ElevatedButton(
              onPressed: () async {
                FilePickerResult? result =
                await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['docx'],
                );

                if (result != null) {
                  File file = File(result.files.single.path!);
                  con.convertDoc(file); // ONLY CONVERT
                }
              },
              child: const Text("Pick DOCX & Convert"),
            ),

            const SizedBox(height: 20),



          ],
        ),
      ),
    );
  }
}

import 'package:converter/view/docall/controller/file_converter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class FileManagerScreen extends StatelessWidget {
  FileManagerScreen({super.key});

  final controller = Get.put(FileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("File → PDF Manager")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SafeArea(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: controller.pickFile,
                child: const Text("Pick Word/PPT/CSV File"),
              ),
              const SizedBox(height: 10),

              Obx(() {
                if (controller.pickedFile.value != null) {
                  return Text(
                    'Picked: ${controller.pickedFile.value!.path.split('/').last}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                }
                return const SizedBox();
              }),

              const SizedBox(height: 10),

              Obx(() {
                return ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.convertToPdf,
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Convert to PDF"),
                );
              }),

              const SizedBox(height: 10),

              Obx(() {
                if (controller.pdfFile.value != null) {
                  return Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: SfPdfViewer.file(controller.pdfFile.value!),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.open_in_new),
                                label: const Text("Open in App"),
                                onPressed: controller.openPdfExternal,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.share),
                                label: const Text("Share PDF"),
                                onPressed: controller.sharePdf,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              }),
            ],
          ),
        ),
      ),
    );
  }
}

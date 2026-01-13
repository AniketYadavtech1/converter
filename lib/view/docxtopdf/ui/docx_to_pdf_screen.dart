import 'package:converter/view/docxtopdf/controller/docx_to_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:docx_file_viewer/docx_file_viewer.dart';

class DocxScreen extends StatelessWidget {
  DocxScreen({super.key});

  final DocxController controller = Get.put(DocxController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DOCX Viewer → PDF")),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: controller.pickDocx,
                  child: const Text("Pick DOCX File"),
                ),

                const SizedBox(height: 16),

                if (controller.isLoading.value)
                  const CircularProgressIndicator(),

                /// DOCX PREVIEW (REAL VIEWER)
                if (controller.docxFile.value != null)
                  Expanded(
                    child: DocxView.path(
                      controller.docxFile.value!.path,
                      config: DocxViewConfig(
                        enableZoom: true,
                        enableSearch: true,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                /// CONVERT
                if (controller.docxFile.value != null)
                  ElevatedButton(
                    onPressed: controller.convertToPdf,
                    child: const Text("Convert to PDF"),
                  ),

                const SizedBox(height: 8),

                /// OPEN PDF
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:converter/view/doctopdf/controller/doccon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DocxToPdfScreen extends StatelessWidget {
  DocxToPdfScreen({super.key});

  final DocxPdfController controller =
  Get.put(DocxPdfController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DOCX to PDF Converter"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: controller.pickDocxFile,
            icon: const Icon(Icons.upload_file),
            label: const Text("Pick DOCX File"),
          ),
          Obx(() {
            final file = controller.selectedDocx.value;
            if (file == null) return const SizedBox();

            return Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                "Selected: ${file.path.split('/').last}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),

          ElevatedButton.icon(
            onPressed: controller.convertToPdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("Convert to PDF"),
          ),
          const Divider(),
          Expanded(
            child: Obx(() {
              if (controller.pdfFiles.isEmpty) {
                return const Center(
                  child: Text("No PDFs Generated"),
                );
              }
              return ListView.builder(
                itemCount: controller.pdfFiles.length,
                itemBuilder: (_, index) {
                  final file = controller.pdfFiles[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading:
                      const Icon(Icons.picture_as_pdf),
                      title:
                      Text(file.path.split('/').last),
                      subtitle: const Text("Tap to open"),
                      onTap: () =>
                          controller.openPdf(file),
                      trailing: IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () =>
                            controller.sharePdf(file),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

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
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          /// Pick DOCX
          ElevatedButton.icon(
            onPressed: controller.pickDocxFile,
            icon: const Icon(Icons.upload_file),
            label: const Text("Pick DOCX File"),
          ),

          /// Selected File
          Obx(() {
            if (controller.selectedDocx.value == null) {
              return const SizedBox();
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Selected: ${controller.selectedDocx.value!.path.split('/').last}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }),

          /// Convert
          ElevatedButton.icon(
            onPressed: controller.convertToPdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("Convert to PDF"),
          ),

          const Divider(),

          /// PDF List
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
                    child: ListTile(
                      leading:
                      const Icon(Icons.picture_as_pdf),
                      title:
                      Text(file.path.split('/').last),
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

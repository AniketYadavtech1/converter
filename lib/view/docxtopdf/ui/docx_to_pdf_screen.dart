import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/docx_to_pdf_controller.dart';

class DocxToPdfScreen extends StatelessWidget {
  DocxToPdfScreen({super.key});

  final controller = Get.put(DocxToPdfController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DOCX → PDF Converter'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
              () => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // File picker card
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        controller.docxFile.value != null
                            ? Icons.description
                            : Icons.upload_file,
                        size: 48,
                        color: controller.docxFile.value != null
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      if (controller.docxFile.value == null)
                        const Text(
                          'No file selected',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        Text(
                          controller.docxFile.value!.path.split('/').last,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.pickDocxFile,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Select DOCX File'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Convert button
              ElevatedButton.icon(
                onPressed: controller.docxFile.value == null ||
                    controller.isLoading.value
                    ? null
                    : controller.convertDocxToPdf,
                icon: controller.isLoading.value
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.picture_as_pdf),
                label: Text(
                  controller.isLoading.value
                      ? 'Converting...'
                      : 'Convert to PDF',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // PDF actions
              if (controller.pdfFile.value != null) ...[
                const Divider(),
                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'PDF Ready',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: controller.clearFiles,
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.openPdf,
                        icon: const Icon(Icons.visibility),
                        label: const Text('View'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.sharePdf,
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  'Saved: ${controller.pdfFile.value!.path.split('/').last}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const Spacer(),

              // Info text
              const Text(
                'Select a .docx file and convert it to PDF format',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
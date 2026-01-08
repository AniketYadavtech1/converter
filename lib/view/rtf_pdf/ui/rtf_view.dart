import 'package:converter/view/rtf_pdf/controller/rtf_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RtfToPdfScreen extends StatelessWidget {
  RtfToPdfScreen({super.key});

  final RtfPdfController controller = Get.put(RtfPdfController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RTF to PDF (GetX)")),
      body: Column(
        children: [
          const SizedBox(height: 16),

          /// Pick RTF
          ElevatedButton.icon(
            onPressed: controller.pickRtfFile,
            icon: const Icon(Icons.upload_file),
            label: const Text("Pick RTF File"),
          ),

          /// Selected File Name
          Obx(() {
            if (controller.selectedRtfFile.value == null) {
              return const SizedBox();
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Selected: ${controller.selectedRtfFile.value!.path.split('/').last}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }),

          /// Convert Button
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
                return const Center(child: Text("No PDFs Generated"));
              }

              return ListView.builder(
                itemCount: controller.pdfFiles.length,
                itemBuilder: (_, index) {
                  final file = controller.pdfFiles[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: const Icon(Icons.picture_as_pdf),
                      title: Text(file.path.split('/').last),
                      trailing: IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () => controller.sharePdf(file),
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

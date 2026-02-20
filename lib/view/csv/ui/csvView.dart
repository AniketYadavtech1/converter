import 'package:converter/view/csv/component/pdf_view.dart';
import 'package:converter/view/csv/controller/csv_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CsvViewScreen extends StatelessWidget {
  CsvViewScreen({super.key});

  final con = Get.put(CsvToPdfController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CSV → PDF")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: GetBuilder<CsvToPdfController>(
            builder: (_) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: con.pickCsvFile,
                    child: const Text("Pick CSV"),
                  ),

                  if (con.csvData.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: con.csvData.first
                              .map((e) => DataColumn(label: Text(e.toString())))
                              .toList(),
                          rows: con.csvData
                              .skip(1)
                              .map(
                                (row) => DataRow(
                                  cells: row
                                      .map(
                                        (cell) =>
                                            DataCell(Text(cell.toString())),
                                      )
                                      .toList(),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),

                  ElevatedButton(
                    onPressed: con.isLoading.value ? null : con.convertCsvToPdf,
                    child: const Text("Convert to PDF"),
                  ),

                  if (con.isLoading.value)
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(),
                    ),

                  if (con.generatedPdfFile != null) ...[
                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () {
                        Get.to(
                          () => PdfViewScreen(pdfFile: con.generatedPdfFile!),
                        );
                      },
                      child: const Text("View PDF in App"),
                    ),

                    // ElevatedButton.icon(
                    //   icon: const Icon(Icons.open_in_new),
                    //   label: const Text("Open in Another App"),
                    //   onPressed: con.openPdfExternal,
                    // ),

                    ElevatedButton.icon(
                      icon: Icon(Icons.share),
                      label: Text("Share PDF"),
                      onPressed: con.sharePdf,
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}


// Future<void> compressImage() async {
//   if (originalImage.value == null) return;
//
//   final dir = await getTemporaryDirectory();
//   final targetPath = "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
//
//   final result = await FlutterImageCompress.compressAndGetFile(
//     originalImage.value!.path,
//     targetPath,
//     quality: 60, // 🔥 keep between 50–70
//   );
//
//   if (result == null) return;
//
//   final originalBytes = await originalImage.value!.length();
//   final compressedBytes = await result.length();
//
//   // 🔥 VERY IMPORTANT CHECK
//   if (compressedBytes < originalBytes) {
//     compressedImage.value = File(result.path);
//
//     originalSize.value = originalBytes.toDouble();
//     compressedSize.value = compressedBytes.toDouble();
//
//     savedPercentage.value = ((originalBytes - compressedBytes) / originalBytes) * 100;
//   } else {
//     // ❌ If compression increased size
//     compressedImage.value = originalImage.value;
//     originalSize.value = originalBytes.toDouble();
//     compressedSize.value = originalBytes.toDouble();
//     savedPercentage.value = 0;
//   }
// }

// Future<void> compressImage() async {
//   if (originalImage.value == null) return;
//
//   final dir = await getTemporaryDirectory();
//   final targetPath = "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
//
//   final result = await FlutterImageCompress.compressAndGetFile(
//     originalImage.value!.path,
//     targetPath,
//     quality: 60, // 🔥 keep between 50–70
//   );
//
//   if (result == null) return;
//
//   final originalBytes = await originalImage.value!.length();
//   final compressedBytes = await result.length();
//
//   // 🔥 VERY IMPORTANT CHECK
//   if (compressedBytes < originalBytes) {
//     compressedImage.value = File(result.path);
//
//     originalSize.value = originalBytes.toDouble();
//     compressedSize.value = compressedBytes.toDouble();
//
//     savedPercentage.value = ((originalBytes - compressedBytes) / originalBytes) * 100;
//   } else {
//     // ❌ If compression increased size
//     compressedImage.value = originalImage.value;
//     originalSize.value = originalBytes.toDouble();
//     compressedSize.value = originalBytes.toDouble();
//     savedPercentage.value = 0;
//   }
// }

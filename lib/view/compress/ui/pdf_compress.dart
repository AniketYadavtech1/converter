// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:simple_pdf_compression/simple_pdf_compression.dart'; // ✅ CORRECT import
//
//
// class PdfController extends GetxController {
//   Rx<File?> originalFile = Rx<File?>(null);
//   Rx<File?> compressedFile = Rx<File?>(null);
//   RxDouble originalSize = 0.0.obs;
//   RxDouble compressedSize = 0.0.obs;
//   RxBool isLoading = false.obs;
//   RxDouble compressionProgress = 0.0.obs;
//
//   // Compression levels available
//   enum CompressionOption { best, normal, low }
//   final Rx<CompressionOption> selectedCompression = CompressionOption.normal.obs;
//
//   Future<void> pickPdf() async {
//   try {
//   FilePickerResult? result = await FilePicker.platform.pickFiles(
//   type: FileType.custom,
//   allowedExtensions: ['pdf'],
//   allowMultiple: false,
//   );
//
//   if (result != null) {
//   originalFile.value = File(result.files.single.path!);
//   originalSize.value = await _getFileSize(originalFile.value!);
//   compressedFile.value = null;
//   compressedSize.value = 0.0;
//
//   Get.snackbar(
//   "✅ Success",
//   "PDF selected: ${_formatFileSize(originalSize.value)}",
//   backgroundColor: Colors.green,
//   colorText: Colors.white,
//   );
//   }
//   } catch (e) {
//   Get.snackbar("❌ Error", "Failed to pick PDF: ${e.toString()}");
//   }
//   }
//
//   Future<void> compressPdfFile() async {
//   if (originalFile.value == null) {
//   Get.snackbar("⚠️ Warning", "Please select a PDF first");
//   return;
//   }
//
//   isLoading.value = true;
//   compressionProgress.value = 0.3;
//
//   try {
//   // Map compression level
//   PdfCompressionLevel level;
//   switch (selectedCompression.value) {
//   case CompressionOption.best:
//   level = PdfCompressionLevel.best; // Maximum compression
//   break;
//   case CompressionOption.normal:
//   level = PdfCompressionLevel.normal; // Balanced
//   break;
//   case CompressionOption.low:
//   level = PdfCompressionLevel.low; // Minimum compression
//   break;
//   }
//
//   compressionProgress.value = 0.6;
//
//   // Compress PDF (FREE to use!)
//   File compressed = await FileCompressor.compressPdf(
//   file: originalFile.value!,
//   compressionLevel: level,
//   );
//
//   compressionProgress.value = 0.9;
//
//   compressedFile.value = compressed;
//   compressedSize.value = await _getFileSize(compressed);
//   compressionProgress.value = 1.0;
//
//   Get.snackbar(
//   "✅ Success",
//   _getCompressionMessage(),
//   backgroundColor: Colors.green,
//   colorText: Colors.white,
//   duration: const Duration(seconds: 4),
//   );
//   } catch (e) {
//   Get.snackbar("❌ Error", "Compression failed: ${e.toString()}");
//   } finally {
//   isLoading.value = false;
//   compressionProgress.value = 0.0;
//   }
//   }
//
//   Future<void> savePdf() async {
//   if (compressedFile.value == null) {
//   Get.snackbar("⚠️ Warning", "No compressed PDF to save");
//   return;
//   }
//
//   try {
//   Directory? saveDir;
//
//   if (Platform.isAndroid) {
//   final downloadDir = Directory('/storage/emulated/0/Download');
//   if (await downloadDir.exists()) {
//   saveDir = downloadDir;
//   } else {
//   saveDir = await getExternalStorageDirectory();
//   }
//   } else {
//   saveDir = await getApplicationDocumentsDirectory();
//   }
//
//   final timestamp = DateTime.now().millisecondsSinceEpoch;
//   final fileName = 'compressed_pdf_$timestamp.pdf';
//   final savePath = '${saveDir!.path}/$fileName';
//
//   await compressedFile.value!.copy(savePath);
//
//   Get.snackbar(
//   "✅ Saved",
//   "PDF saved to:\n$savePath",
//   backgroundColor: Colors.green,
//   colorText: Colors.white,
//   duration: const Duration(seconds: 4),
//   );
//   } catch (e) {
//   // Fallback
//   try {
//   final appDir = await getApplicationDocumentsDirectory();
//   final timestamp = DateTime.now().millisecondsSinceEpoch;
//   final fileName = 'compressed_pdf_$timestamp.pdf';
//   final savePath = '${appDir.path}/$fileName';
//   await compressedFile.value!.copy(savePath);
//   Get.snackbar("✅ Saved", "PDF saved to app storage");
//   } catch (fallbackError) {
//   Get.snackbar("❌ Error", "Could not save PDF");
//   }
//   }
//   }
//
//   Future<double> _getFileSize(File file) async {
//   try {
//   int bytes = await file.length();
//   return bytes / (1024 * 1024);
//   } catch (e) {
//   return 0.0;
//   }
//   }
//
//   String _getCompressionMessage() {
//   if (originalSize.value == 0 || compressedSize.value == 0) {
//   return "PDF Compressed Successfully";
//   }
//
//   double saved = originalSize.value - compressedSize.value;
//   double percentage = savedPercentage;
//
//   if (percentage > 0) {
//   return "Reduced from ${_formatFileSize(originalSize.value)} to ${_formatFileSize(compressedSize.value)}\nSaved: ${_formatFileSize(saved)} (${percentage.toStringAsFixed(1)}%)";
//   } else {
//   return "File size remained similar";
//   }
//   }
//
//   double get savedPercentage {
//   if (originalSize.value == 0 || compressedSize.value == 0) return 0;
//   return ((originalSize.value - compressedSize.value) / originalSize.value) * 100;
//   }
//
//   String _formatFileSize(double sizeInMB) {
//   if (sizeInMB < 0.001) {
//   return '${(sizeInMB * 1024 * 1024).toStringAsFixed(0)} B';
//   } else if (sizeInMB < 1) {
//   return '${(sizeInMB * 1024).toStringAsFixed(1)} KB';
//   }
//   return '${sizeInMB.toStringAsFixed(2)} MB';
//   }
//
//   void setCompressionLevel(CompressionOption level) {
//   selectedCompression.value = level;
//   }
//
//   void reset() {
//   originalFile.value = null;
//   compressedFile.value = null;
//   originalSize.value = 0.0;
//   compressedSize.value = 0.0;
//   isLoading.value = false;
//   compressionProgress.value = 0.0;
//   selectedCompression.value = CompressionOption.normal;
//   }
// }
//
//
//
//
//
//
//
//
//
//
//
// class PdfScreen extends StatelessWidget {
//   PdfScreen({super.key});
//
//   final PdfController controller = Get.put(PdfController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("PDF Compressor")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Obx(() {
//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 ElevatedButton(
//                   onPressed: controller.pickPdf,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                   ),
//                   child: const Text("Pick PDF", style: TextStyle(fontSize: 16)),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 if (controller.originalFile.value != null)
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Original File",
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           "Size: ${controller.originalSize.value.toStringAsFixed(2)} MB",
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           "Path: ${controller.originalFile.value!.path.split('/').last}",
//                           style: TextStyle(
//                               fontSize: 14, color: Colors.grey.shade600),
//                         ),
//                         const SizedBox(height: 15),
//
//                         ElevatedButton(
//                           onPressed: controller.isLoading.value
//                               ? null
//                               : controller.compressPdfFile,
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 15),
//                           ),
//                           child: const Text("Compress PDF",
//                               style: TextStyle(fontSize: 16)),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                 const SizedBox(height: 20),
//
//                 if (controller.isLoading.value)
//                   const Column(
//                     children: [
//                       CircularProgressIndicator(),
//                       SizedBox(height: 10),
//                       Text("Compressing PDF..."),
//                     ],
//                   ),
//
//                 if (controller.compressedFile.value != null)
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.green.shade300),
//                       borderRadius: BorderRadius.circular(10),
//                       color: Colors.green.shade50,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Compressed File",
//                           style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           "Original: ${controller.originalSize.value.toStringAsFixed(2)} MB",
//                           style: const TextStyle(fontSize: 14),
//                         ),
//                         Text(
//                           "Compressed: ${controller.compressedSize.value.toStringAsFixed(2)} MB",
//                           style: const TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 5),
//                         Text(
//                           "Saved: ${controller.savedPercentage.toStringAsFixed(1)}%",
//                           style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: controller.savedPercentage > 0
//                                   ? Colors.green
//                                   : Colors.red),
//                         ),
//                         const SizedBox(height: 15),
//
//                         ElevatedButton(
//                           onPressed: controller.savePdf,
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 15),
//                             backgroundColor: Colors.green,
//                           ),
//                           child: const Text("Save PDF to Device",
//                               style: TextStyle(fontSize: 16)),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
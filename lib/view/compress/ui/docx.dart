import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:universal_file_viewer/universal_file_viewer.dart' hide FileType;


class DocxController extends GetxController {
  Rx<File?> originalFile = Rx<File?>(null);
  Rx<File?> compressedFile = Rx<File?>(null);

  RxString originalSize = ''.obs;
  RxString compressedSize = ''.obs;
  RxBool isLoading = false.obs;

  Future<void> pickDocx() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['docx']);

    if (result == null) return;

    File file = File(result.files.single.path!);
    originalFile.value = file;
    originalSize.value = await _getFileSize(file);
    compressedFile.value = null;
  }

  Future<void> compressDocx() async {
    if (originalFile.value == null) return;
    try {
      isLoading.value = true;

      final bytes = await originalFile.value!.readAsBytes();
      Archive archive = ZipDecoder().decodeBytes(bytes);
      Archive newArchive = Archive();

      for (ArchiveFile file in archive) {
        if (file.isFile && file.name.startsWith('word/media/')) {
          if (file.name.endsWith('.png') || file.name.endsWith('.jpg') || file.name.endsWith('.jpeg')) {
            img.Image? image = img.decodeImage(file.content);

            if (image != null) {
              img.Image resized = img.copyResize(image, width: (image.width * 0.6).toInt());

              List<int> compressedImage;

              if (file.name.endsWith('.png')) {
                compressedImage = img.encodePng(resized, level: 9);
              } else {
                compressedImage = img.encodeJpg(resized, quality: 60);
              }

              newArchive.addFile(ArchiveFile(file.name, compressedImage.length, compressedImage));
            }
          } else {
            newArchive.addFile(file);
          }
        } else {
          newArchive.addFile(file);
        }
      }

      final compressedData = ZipEncoder().encode(newArchive, level: 9);

      final dir = await getTemporaryDirectory();
      final outputFile = File("${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.docx");

      await outputFile.writeAsBytes(compressedData!);

      compressedFile.value = outputFile;
      compressedSize.value = await _getFileSize(outputFile);

      Get.snackbar("Success", "DOCX Compressed Successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveToDownloads() async {
    if (compressedFile.value == null) return;

    await Permission.storage.request();

    final downloadsDir = Directory('/storage/emulated/0/Download');

    final newFile = File("${downloadsDir.path}/${compressedFile.value!.path.split('/').last}");

    await newFile.writeAsBytes(await compressedFile.value!.readAsBytes());

    Get.snackbar("Saved", "File saved to Downloads");
  }

  Future<String> _getFileSize(File file) async {
    int bytes = await file.length();
    double kb = bytes / 1024;
    double mb = kb / 1024;

    if (mb >= 1) {
      return "${mb.toStringAsFixed(2)} MB";
    } else {
      return "${kb.toStringAsFixed(2)} KB";
    }
  }


  double calculateSavedPercentage() {
    if (originalFile.value == null || compressedFile.value == null) return 0;

    final originalBytes = originalFile.value!.lengthSync();
    final compressedBytes = compressedFile.value!.lengthSync();

    double saved = ((originalBytes - compressedBytes) / originalBytes) * 100;

    return saved.isNegative ? 0 : double.parse(saved.toStringAsFixed(1));
  }
}

class DocxCompressionScreen extends StatefulWidget {
  const DocxCompressionScreen({super.key});

  @override
  State<DocxCompressionScreen> createState() =>
      _DocxCompressionScreenState();
}

class _DocxCompressionScreenState
    extends State<DocxCompressionScreen> {
  final controller = Get.put(DocxController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("DOCX Compressor"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(
            () => LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 40.w,
                vertical: 30.h,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      /// PICK BUTTON
                      ElevatedButton.icon(
                        icon: const Icon(Icons.upload_file),
                        label: const Text("Pick DOCX File"),
                        onPressed: controller.pickDocx,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.w, vertical: 15.h),
                        ),
                      ),

                      SizedBox(height: 30.h),

                      /// ORIGINAL FILE CARD
                      if (controller.originalFile.value != null)
                        _fileCard(
                          title: "Original File",
                          fileName: controller.originalFile.value!.path
                              .split('/')
                              .last,
                          size: controller.originalSize.value,
                          color: Colors.blue,
                        ),

                      SizedBox(height: 20.h),

                      /// FILE PREVIEW
                      if (controller.originalFile.value != null)
                        Container(
                          height: 400.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.grey.shade300),
                            color: Colors.white,
                          ),
                          // child: ClipRRect(
                          //   borderRadius: BorderRadius.circular(16),
                          //   child: UniversalFileViewer(
                          //     file: controller.originalFile.value!,
                          //   ),
                          // ),
                        ),

                      SizedBox(height: 25.h),

                      /// COMPRESS BUTTON
                      if (controller.originalFile.value != null)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.compress),
                          label: const Text("Compress File"),
                          onPressed: controller.compressDocx,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30.w,
                                vertical: 15.h),
                          ),
                        ),

                      SizedBox(height: 25.h),

                      /// LOADING
                      if (controller.isLoading.value)
                        Column(
                          children: [
                            const CircularProgressIndicator(),
                            SizedBox(height: 10.h),
                            const Text("Compressing... Please wait"),
                          ],
                        ),

                      SizedBox(height: 30.h),

                      /// COMPRESSED FILE CARD
                      if (controller.compressedFile.value != null)
                        _fileCard(
                          title: "Compressed File",
                          fileName: controller
                              .compressedFile.value!.path
                              .split('/')
                              .last,
                          size: controller.compressedSize.value,
                          color: Colors.green,
                        ),

                      SizedBox(height: 15.h),

                      /// SAVED PERCENTAGE
                      if (controller.compressedFile.value != null)
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          child: Text(
                            "You saved ${controller.calculateSavedPercentage()} %",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),

                      SizedBox(height: 25.h),

                      /// DOWNLOAD BUTTON
                      if (controller.compressedFile.value != null)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text(
                              "Download Compressed File"),
                          onPressed: controller.saveToDownloads,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30.w,
                                vertical: 15.h),
                          ),
                        ),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _fileCard({
    required String title,
    required String fileName,
    required String size,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 10.h),
          Text("Name: $fileName"),
          Text("Size: $size"),
        ],
      ),
    );
  }
}
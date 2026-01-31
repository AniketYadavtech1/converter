import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:xml/xml.dart';

class DocxController extends GetxController {

  Rx<File?> docxFile = Rx<File?>(null);
  Rx<File?> pdfFile = Rx<File?>(null);
  RxString extractedText = "".obs;
  RxBool isLoading = false.obs;

  Future<void> pickDocx() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
    );

    if (result != null) {
      docxFile.value = File(result.files.single.path!);
      await _extractTextFromDocx();
    }
  }

  Future<void> _extractTextFromDocx() async {
    isLoading.value = true;

    final bytes = await docxFile.value!.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final documentFile =
    archive.files.firstWhere((f) => f.name == 'word/document.xml');

    final xmlDoc = XmlDocument.parse(
      String.fromCharCodes(documentFile.content),
    );

    final buffer = StringBuffer();
    for (final e in xmlDoc.findAllElements('w:t')) {
      buffer.write(e.text);
      buffer.write(' ');
    }

    extractedText.value = buffer.toString().trim();
    isLoading.value = false;
  }

  /// Convert DOCX → PDF
  Future<void> convertToPdf() async {
    if (extractedText.value.isEmpty) {
      Get.snackbar("Error", "No text found in DOCX");
      return;
    }

    isLoading.value = true;

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(extractedText.value),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    pdfFile.value = File("${dir.path}/docx_converted.pdf");

    await pdfFile.value!.writeAsBytes(await pdf.save());

    isLoading.value = false;
  }

  void sharePdf() {
    if (pdfFile.value != null) {
      Share.shareXFiles([XFile(pdfFile.value!.path)]);
    }
  }
}

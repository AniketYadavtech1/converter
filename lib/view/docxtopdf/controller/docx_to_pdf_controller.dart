import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:xml/xml.dart';

class DocxToPdfController extends GetxController {
  Rx<File?> docxFile = Rx<File?>(null);
  Rx<File?> pdfFile = Rx<File?>(null);
  RxBool isLoading = false.obs;

  /// Pick DOCX
  Future<void> pickDocxFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
    );

    if (result != null && result.files.single.path != null) {
      docxFile.value = File(result.files.single.path!);
      pdfFile.value = null;
    }
  }

  /// Extract paragraphs from DOCX
  Future<List<String>> _extractTextFromDocx(File file) async {
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final paragraphs = <String>[];
//
    final docFile =
    archive.files.firstWhere((f) => f.name == 'word/document.xml');

    final xmlString = String.fromCharCodes(docFile.content as List<int>);
    final document = XmlDocument.parse(xmlString);

    for (final para in document.findAllElements('w:p')) {
      final buffer = StringBuffer();
      for (final text in para.findAllElements('w:t')) {
        buffer.write(text.innerText);
      }
      if (buffer.toString().trim().isNotEmpty) {
        paragraphs.add(buffer.toString());
      }
    }

    return paragraphs;
  }

  /// Convert DOCX → PDF (SAFE pagination)
  Future<void> convertDocxToPdf() async {
    if (docxFile.value == null) {
      Get.snackbar("Error", "Please select a DOCX file");
      return;
    }

    try {
      isLoading.value = true;

      final paragraphs = await _extractTextFromDocx(docxFile.value!);

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (_) => paragraphs
              .map(
                (p) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                p,
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
          )
              .toList(),
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        "${dir.path}/docx_${DateTime.now().millisecondsSinceEpoch}.pdf",
      );

      await file.writeAsBytes(await pdf.save());
      pdfFile.value = file;

      Get.snackbar("Success", "PDF created successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Open PDF
  void openPdf() {
    if (pdfFile.value != null) {
      OpenFilex.open(pdfFile.value!.path);
    }
  }

  /// Share PDF
  void sharePdf() {
    if (pdfFile.value != null) {
      Share.shareXFiles([XFile(pdfFile.value!.path)]);
    }
  }

  void clearFiles() {
    docxFile.value = null;
    pdfFile.value = null;
  }
}

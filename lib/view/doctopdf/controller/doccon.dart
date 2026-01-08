import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:xml/xml.dart';

class DocxPdfController extends GetxController {
  Rx<File?> selectedDocx = Rx<File?>(null);
  RxList<File> pdfFiles = <File>[].obs;

  /// Pick DOCX
  Future<void> pickDocxFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
    );

    if (result != null) {
      selectedDocx.value = File(result.files.single.path!);
    }
  }

  /// Extract text from DOCX (CORRECT WAY)
  Future<String> extractTextFromDocx(File file) async {
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final documentFile = archive.files.firstWhere(
          (f) => f.name == 'word/document.xml',
    );

    final xmlData =
    String.fromCharCodes(documentFile.content as Uint8List);

    final xmlDoc = XmlDocument.parse(xmlData);

    final buffer = StringBuffer();

    /// Loop paragraphs
    for (final paragraph in xmlDoc.findAllElements('w:p')) {
      for (final node in paragraph.findAllElements('w:t')) {
        buffer.write(node.text);
      }
      buffer.writeln(); // new line after paragraph
    }

    return buffer.toString();
  }

  /// Convert DOCX → PDF (FIXED)
  Future<void> convertToPdf() async {
    if (selectedDocx.value == null) return;

    final text = await extractTextFromDocx(selectedDocx.value!);

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            text,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        "docx_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final file = File('${dir.path}/$fileName');

    await file.writeAsBytes(await pdf.save());
    pdfFiles.add(file);
  }

  /// Share PDF
  Future<void> sharePdf(File file) async {
    await Share.shareXFiles([XFile(file.path)]);
  }
}

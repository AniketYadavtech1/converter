import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:xml/xml.dart';
import 'package:open_filex/open_filex.dart';

class DocxPdfController extends GetxController {
  Rx<File?> selectedDocx = Rx<File?>(null);
  RxList<File> pdfFiles = <File>[].obs;


  Future<void> pickDocxFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
    );

    if (result != null && result.files.single.path != null) {
      selectedDocx.value = File(result.files.single.path!);
    }
  }


  Future<String> extractTextFromDocx(File file) async {
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final documentFile = archive.files.firstWhere(
          (f) => f.name == 'word/document.xml',
    );
    final xmlData =
    String.fromCharCodes(documentFile.content);
    final xmlDoc = XmlDocument.parse(xmlData);
    final buffer = StringBuffer();
    for (final paragraph in xmlDoc.findAllElements('w:p')) {
      for (final node in paragraph.findAllElements('w:t')) {
        buffer.write(node.text);
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  Future<void> convertToPdf() async {
    if (selectedDocx.value == null) {
      Get.snackbar("Error", "Please pick a DOCX file first");
      return;
    }

    final text = await extractTextFromDocx(selectedDocx.value!);

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (_) => [
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
    final file = File("${dir.path}/$fileName");
    await file.writeAsBytes(await pdf.save());
    pdfFiles.add(file);
    Get.snackbar("Success", "PDF created successfully");
  }
  Future<void> sharePdf(File file) async {
    await Share.shareXFiles([XFile(file.path)]);
  }
  Future<void> openPdf(File file) async {
    await OpenFilex.open(file.path);
  }
}

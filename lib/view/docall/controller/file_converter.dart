import 'dart:io';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class FileController extends GetxController {
  Rxn<File> pickedFile = Rxn<File>();
  Rxn<File> pdfFile = Rxn<File>();
  RxBool isLoading = false.obs;

  // Pick Word/PPT/CSV
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['doc', 'docx', 'ppt', 'pptx', 'csv'],
    );

    if (result != null && result.files.single.path != null) {
      pickedFile.value = File(result.files.single.path!);
    }
  }

  // Convert picked file to PDF (simple text for Word/PPT/CSV)
  Future<void> convertToPdf() async {
    if (pickedFile.value == null) return;

    isLoading.value = true;

    final content = pickedFile.value!.path.split('/').last;

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (_) => pw.Center(
          child: pw.Text(
            'File: $content\n\n(You can implement full parsing)',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 20),
          ),
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/converted.pdf');
    await file.writeAsBytes(await pdf.save());

    pdfFile.value = file;
    isLoading.value = false;
  }

  // Open PDF in native apps
  void openPdfExternal() {
    if (pdfFile.value != null) OpenFilex.open(pdfFile.value!.path);
  }

  // Share PDF
  void sharePdf() {
    if (pdfFile.value != null) {
      Share.shareXFiles([XFile(pdfFile.value!.path)], text: 'Here is your PDF');
    }
  }
}

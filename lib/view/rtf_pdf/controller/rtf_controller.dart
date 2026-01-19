import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class RtfPdfController extends GetxController {
  /// Selected RTF file
  Rx<File?> selectedRtfFile = Rx<File?>(null);

  /// Generated PDF list
  RxList<File> pdfFiles = <File>[].obs;

  /// Pick RTF file
  Future<void> pickRtfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['rtf'],
    );

    if (result != null) {
      selectedRtfFile.value = File(result.files.single.path!);
    }
  }

  /// Convert RTF → Plain Text
  String _rtfToText(String rtf) {
    return rtf
        .replaceAll(RegExp(r'{\\[^}]+}'), '')
        .replaceAll(RegExp(r'\\[a-zA-Z]+\d*'), '')
        .replaceAll(RegExp(r'[{}]'), '')
        .trim();
  }

  /// Convert RTF → PDF
  Future<void> convertToPdf() async {
    if (selectedRtfFile.value == null) return;

    final rtfContent = await selectedRtfFile.value!.readAsString();
    final text = _rtfToText(rtfContent);

    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (_) => pw.Text(text)));

    final dir = await getApplicationDocumentsDirectory();
    final fileName = "rtf_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final file = File('${dir.path}/$fileName');

    await file.writeAsBytes(await pdf.save());
    pdfFiles.add(file);
  }

  /// Share PDF
  Future<void> sharePdf(File file) async {
    await Share.shareXFiles([XFile(file.path)]);
  }
}

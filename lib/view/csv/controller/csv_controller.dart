import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class CsvToPdfController extends GetxController {
  File? selectedCsvFile;
  File? generatedPdfFile;

  RxBool isLoading = false.obs;
  List<List<dynamic>> csvData = [];

  Future<void> pickCsvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      selectedCsvFile = File(result.files.single.path!);
      final csvString = await selectedCsvFile!.readAsString();
      csvData = const CsvToListConverter().convert(csvString);
      update();
    }
  }

  Future<void> convertCsvToPdf() async {
    if (csvData.isEmpty) return;

    isLoading.value = true;
    update();

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text(
            'CSV to PDF',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(data: csvData),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    generatedPdfFile = File('${dir.path}/csv_output.pdf');
    await generatedPdfFile!.writeAsBytes(await pdf.save());

    isLoading.value = false;
    update();
  }

  void openPdfExternal() {
    if (generatedPdfFile != null) {
      OpenFilex.open(generatedPdfFile!.path);
    }
  }

  void sharePdf() {
    if (generatedPdfFile != null) {
      Share.shareXFiles([
        XFile(generatedPdfFile!.path),
      ], text: "CSV to PDF file");
    }
  }
}

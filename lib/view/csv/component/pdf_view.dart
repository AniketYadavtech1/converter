import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewScreen extends StatelessWidget {
  final File pdfFile;

  const PdfViewScreen({super.key, required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Preview")),
      body: PDFView(
        filePath: pdfFile.path,
        enableSwipe: true,
        autoSpacing: true,
        pageFling: true,
      ),
    );
  }
}

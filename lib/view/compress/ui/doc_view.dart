import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_docx_viewer/flutter_docx_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DocxViewerScreen(),
    );
  }
}

class DocxViewerScreen extends StatefulWidget {
  const DocxViewerScreen({super.key});

  @override
  State<DocxViewerScreen> createState() => _DocxViewerScreenState();
}

class _DocxViewerScreenState extends State<DocxViewerScreen> {
  File? selectedFile;

  Future<void> pickDocxFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DOCX Viewer"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: pickDocxFile,
            child: const Text("Pick DOCX File"),
          ),

          const SizedBox(height: 20),

          // Expanded(
          //   child: selectedFile != null
          //       ? DocxViewer(
          //     filePath: selectedFile!.path,
          //   )
          //       : const Center(
          //     child: Text("No File Selected"),
          //   ),
          // ),
        ],
      ),
    );
  }
}
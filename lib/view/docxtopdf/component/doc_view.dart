import 'dart:io';
import 'package:docx_file_viewer/docx_file_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class WordViewerScreen extends StatefulWidget {
  const WordViewerScreen({super.key});

  @override
  State<WordViewerScreen> createState() => _WordViewerScreenState();
}

class _WordViewerScreenState extends State<WordViewerScreen> {
  File? selectedFile;
  Future<void> pickWordFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Word File Viewer"), centerTitle: true),

      floatingActionButton: FloatingActionButton(
        onPressed: pickWordFile,
        child: const Icon(Icons.upload_file),
      ),

      body: selectedFile == null
          ? const Center(child: Text("Select a Word File"))
          : Container(
              color: Colors.grey.shade200,

              child: DocxView.file(
                selectedFile!,

                config: DocxViewConfig(
                  backgroundColor: Colors.white,

                  enableZoom: true,
                ),
              ),
            ),
    );
  }
}

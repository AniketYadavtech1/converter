import 'dart:io';

import 'package:flutter/material.dart';
import 'package:docx_file_viewer/docx_file_viewer.dart';

class DocViewerScreen extends StatelessWidget {

  final File file;

  const DocViewerScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(file.path.split('/').last),
      ),

      body: DocxView.file(
        file,
        config: const DocxViewConfig(
          enableZoom: true,
        ),
      ),
    );
  }
}

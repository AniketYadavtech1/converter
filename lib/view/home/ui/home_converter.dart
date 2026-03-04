import 'package:converter/view/compress/ui/docx.dart';
import 'package:converter/view/compress/ui/image_compress.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../compress/ui/audio_compress.dart';
import '../../compress/ui/doc_view.dart';
import '../../compress/ui/gif_file_compress.dart' show GifScreen;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Converter")),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Get.to(ImageCompressScreen());
              },
              child: Text("Image compress"),
            ),
            TextButton(
              onPressed: () {
                Get.to(ImageCompressScreen());
              },
              child: Text("Csv file "),
            ),
            TextButton(
              onPressed: () {
                Get.to(GifScreen());
              },
              child: Text("Gif file "),
            ),
            TextButton(
              onPressed: () {
                Get.to(DocxCompressionScreen());
              },
              child: Text("docx compress"),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Get.to(AudioScreen());
              },
              child: Text("Audio Compress"),
            ),

            TextButton(
              onPressed: () {
                Get.to(DocxViewerScreen());
              },
              child: Text("Doc Viewer"),
            ),
          ],
        ),
      ),
    );
  }
}

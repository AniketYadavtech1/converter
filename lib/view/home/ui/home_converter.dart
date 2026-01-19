import 'package:converter/view/csv/ui/csvView.dart';
import 'package:converter/view/docall/ui/fileview.dart';
import 'package:converter/view/docxtopdf/ui/docx_to_pdf_screen.dart';
import 'package:converter/view/rtf_pdf/ui/rtf_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
            TextButton(
              onPressed: () {
                Get.to(CsvViewScreen());
              },
              child: Text("csv to pdf"),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Get.to(RtfToPdfScreen());
              },
              child: Text("rtf to pdf"),
            ),
            SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Get.to(DocxScreen());
              },
              child: Text("docx to pdf"),
            ),
            TextButton(
              onPressed: () {
                Get.to(FileManagerScreen());
              },
              child: Text("FileConvert"),
            ),
          ],
        ),
      ),
    );
  }
}

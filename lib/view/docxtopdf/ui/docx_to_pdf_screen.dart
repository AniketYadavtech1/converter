import 'package:converter/view/docxtopdf/controller/docx_to_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:docx_file_viewer/docx_file_viewer.dart';

class DocxScreen extends StatelessWidget {
  DocxScreen({super.key});

  final  con = Get.put(DocxController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DOCX Viewer → PDF", style: TextStyle(fontSize: 15)),
      ),
      body: Obx(
        () => SafeArea(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: con.pickDocx,
                child: const Text("Pick DOCX File"),
              ),

              if (con.isLoading.value)
                const CircularProgressIndicator(),

              if (con.docxFile.value != null)
                Expanded(
                  child: DocxView.path(
                    con.docxFile.value!.path,
                    config: DocxViewConfig(
                      pageWidth: MediaQuery.sizeOf(context).width,
                      enableZoom: true,
                      enableSearch: true,
                      pageMode: DocxPageMode.paged
                    ),
                  ),
                ),

              if (con.docxFile.value != null)
                ElevatedButton(
                  onPressed: con.convertToPdf,
                  child: const Text("Convert to PDF"),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

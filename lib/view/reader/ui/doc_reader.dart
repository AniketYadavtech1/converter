import 'dart:io';

import 'package:converter/view/reader/component/component/doc_viewer.dart';
import 'package:converter/view/reader/controller/doc_con.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class DocHomeScreen extends StatelessWidget {

  final DocController controller =
  Get.put(DocController());

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Document Reader"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.scanDocuments();
        },
        child: const Icon(Icons.search),
      ),

      body: Obx(() {

        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.docFiles.isEmpty) {
          return const Center(
            child: Text("No DOC/DOCX Files Found"),
          );
        }

        return ListView.builder(
          itemCount: controller.docFiles.length,
          itemBuilder: (context, index) {

            File file = controller.docFiles[index];

            return ListTile(
              leading: const Icon(Icons.description),
              title: Text(file.path.split('/').last),
              subtitle: Text(file.path),

              onTap: () {
                Get.to(() => DocViewerScreen(file: file));
              },
            );
          },
        );
      }),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import '../controller/controller.dart';

class SavedImagesScreen extends StatelessWidget {
  final ImageConverterController con = Get.find<ImageConverterController>();

  SavedImagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    con.fetchSavedImages(); // Load images when screen opens

    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Images"),
      ),
      body: Obx(() {
        if (con.savedImages.isEmpty) {
          return Center(child: Text("No saved images found"));
        }

        return ListView.builder(
          itemCount: con.savedImages.length,
          itemBuilder: (context, index) {
            final file = con.savedImages[index];
            final ext = p.extension(file.path).replaceAll('.', '').toUpperCase();

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: ListTile(
                leading: Image.file(
                  File(file.path),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
                title: Text(file.path.split("/").last),
                subtitle: Text("Type: $ext"),

                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == "view") {
                      con.viewImage(File(file.path));
                    } else if (value == "share") {
                      con.shareSavedImage(File(file.path));
                    } else if (value == "delete") {
                      con.deleteSavedImage(File(file.path));
                    } else if (value == "openOther") {
                      con.openInOtherApp(File(file.path));
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: "view", child: Text("View Image")),
                    PopupMenuItem(value: "share", child: Text("Share")),
                    PopupMenuItem(value: "delete", child: Text("Delete")),
                    PopupMenuItem(value: "openOther", child: Text("Open in Other App")),
                  ],
                ),
              ),
            );

          },
        );
      }),
    );
  }
}

import 'package:converter/convert/ui/saveimage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/controller.dart';

class ImageConverterScreen extends StatelessWidget {
  final ImageConverterController con = Get.put(ImageConverterController());

  ImageConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Converter")),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: con.pickImage,
                  child: Text("Pick Image"),
                ),
                SizedBox(height: 20),
          
                Obx(
                      () => con.picking.value
                      ? CircularProgressIndicator()
                      : con.selectedImage.value == null
                      ? Text("No image selected")
                      : Image.file(con.selectedImage.value!, height: 200),
                ),
          
                SizedBox(height: 20),
          
                Wrap(
                  spacing: 10,
                  children: [
                    conversionButton("PNG"),
                    conversionButton("JPG"),
                    conversionButton("WEBP"),
                    conversionButton("HEIC"),
                  ],
                ),
          
                SizedBox(height: 20),
          
                Obx(
                      () => con.loading.value
                      ? CircularProgressIndicator()
                      : con.convertedImage.value == null
                      ? Text("No converted image yet")
                      : Image.file(con.convertedImage.value!, height: 200),
                ),
          
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: con.convertedImage.value != null
                      ? con.shareImage
                      : null,
                  child: Text("Share"),
                ),
          
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => SavedImagesScreen());
                  },
                  child: Text("View Saved Images"),
                ),
                ElevatedButton(
                  onPressed: () {
                    con.saveImageToAppDirectory(con.convertedImage.value!);
                    Get.snackbar("Saved", "Image saved successfully");
                  },
                  child: Text("Save Image"),
                ),

          
          
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget conversionButton(String format) {
    return ElevatedButton(
      onPressed: () => con.convertTo(format.toLowerCase()),
      child: Text(format),
    );
  }
}
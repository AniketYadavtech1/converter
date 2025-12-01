import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class ImageConverterController extends GetxController {
  Rxn<File> selectedImage = Rxn<File>();
  Rxn<File> convertedImage = Rxn<File>();
  RxBool loading = false.obs;
  RxBool picking = false.obs;

  Future<void> pickImage() async {
    try {
      picking.value = true;
      convertedImage.value = null;
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.single.path != null) {
        selectedImage.value = File(result.files.single.path!);
      }
      picking.value = false;
    } catch (e) {
      picking.value = false;
    }
  }

  Future<void> convertTo(String format) async {
    if (selectedImage.value == null) return;
    try {
      loading.value = true;
      Uint8List bytes = await selectedImage.value!.readAsBytes();
      String ext = format.toLowerCase();
      List<int>? outputBytes;
      switch (ext) {
        case "jpg":
        case "jpeg":
          outputBytes = await FlutterImageCompress.compressWithList(
            bytes,
            format: CompressFormat.jpeg,
          );
          break;
        case "png":
          outputBytes = await FlutterImageCompress.compressWithList(
            bytes,
            format: CompressFormat.png,
          );
          break;
        case "webp":
          outputBytes = await FlutterImageCompress.compressWithList(
            bytes,
            format: CompressFormat.webp,
          );
          break;
        case "heic":
          outputBytes = await FlutterImageCompress.compressWithList(
            bytes,
            format: CompressFormat.heic,
          );
          break;
        default:
          loading.value = false;
          Get.snackbar("Error", "Format not supported!");
          return;
      }
      final dir = await getTemporaryDirectory();
      final path = p.join(
        dir.path,
        "converted_${DateTime.now().millisecondsSinceEpoch}.$ext",
      );

      File outputFile = File(path)..writeAsBytesSync(outputBytes);
      convertedImage.value = outputFile;
      print("${convertedImage.value}");

      loading.value = false;
    } catch (e) {
      loading.value = false;
    }
  }

  Future<void> shareImage() async {
    try {
      if (convertedImage.value == null) return;
      Share.shareXFiles([XFile(convertedImage.value!.path)]);
    } catch (e) {
      return;
    }
  }

  Future<void> saveImageToAppDirectory(File image) async {
    if (image == null) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final newPath = p.join(
        dir.path,
        "saved_image_${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}",
      );
      final savedFile = await image.copy(newPath);
    } catch (e) {}
  }
}

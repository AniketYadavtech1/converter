import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
// import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioController extends GetxController {
  final recorder = AudioRecorder();
  final audioPlayer = AudioPlayer();

  Rx<File?> originalFile = Rx<File?>(null);
  Rx<File?> compressedFile = Rx<File?>(null);

  RxString originalSize = "".obs;
  RxString compressedSize = "".obs;

  RxBool isLoading = false.obs;
  RxBool isPlaying = false.obs;

  //Pick Audio
  Future<void> pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'aac', 'wav', 'm4a', 'ogg', '.webm'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      originalFile.value = File(result.files.single.path!);
      originalSize.value = _getFileSize(originalFile.value!);
    }
  }

  // Compress Audio (Re-Encode with Low Bitrate)
  // Future<void> compressAudio() async {
  //   if (originalFile.value == null) return;
  //
  //   isLoading.value = true;
  //
  //   final dir = await getTemporaryDirectory();
  //   String outputPath = "${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.aac";
  //
  //   // Start recorder with low bitrate
  //   await recorder.start(
  //     const RecordConfig(
  //       encoder: AudioEncoder.aacLc,
  //       bitRate: 64000, //reduce bitrate (64kbps)
  //       sampleRate: 22050,
  //     ),
  //     path: outputPath,
  //   );
  //
  //   // Read original file and pipe into recorder
  //   // (Simulated re-encoding process)
  //   await Future.delayed(const Duration(seconds: 5));
  //   await recorder.stop();
  //   compressedFile.value = File(outputPath);
  //   compressedSize.value = _getFileSize(compressedFile.value!);
  //   isLoading.value = false;
  // }

  Future<void> compressAudio() async {
    if (originalFile.value == null) return;

    try {
      isLoading.value = true;

      final dir = await getTemporaryDirectory();
      String outputPath = "${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.aac";

      String command =
          '-y -i "${originalFile.value!.path}" '
          '-vn '
          '-acodec aac '
          '-b:a 64k '
          '-ar 22050 '
          '-ac 1 '
          '"$outputPath"';

      // await FFmpegKit.executeAsync(command, (session) async {
      //   final returnCode = await session.getReturnCode();
      //
      //   if (ReturnCode.isSuccess(returnCode)) {
      //     compressedFile.value = File(outputPath);
      //     compressedSize.value = await _getFileSize(compressedFile.value!);
      //
      //     print("Compression Success ");
      //   } else {
      //     print("Compression Failed ");
      //   }
      //
      //   isLoading.value = false;
      // });
    } catch (e) {
      isLoading.value = false;
      print("Error: $e");
    }
  }

  // Play / Pause
  Future<void> togglePlayPause() async {
    if (compressedFile.value == null) return;

    if (isPlaying.value) {
      await audioPlayer.pause();
      isPlaying.value = false;
    } else {
      await audioPlayer.play(DeviceFileSource(compressedFile.value!.path));
      isPlaying.value = true;
    }
  }

  String _getFileSize(File file) {
    int bytes = file.lengthSync();
    double kb = bytes / 1024;
    double mb = kb / 1024;
    return "${mb.toStringAsFixed(2)} MB";
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    recorder.dispose();
    super.onClose();
  }
}

class AudioScreen extends StatelessWidget {
  final controller = Get.put(AudioController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audio Compress (No FFmpeg)"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(onPressed: controller.pickAudio, child: const Text("Pick Audio")),

              const SizedBox(height: 10),

              if (controller.originalFile.value != null) Text("Original Size: ${controller.originalSize.value}"),

              const SizedBox(height: 20),

              ElevatedButton(onPressed: controller.compressAudio, child: const Text("Compress Audio (64kbps)")),

              const SizedBox(height: 20),

              if (controller.isLoading.value) const Center(child: CircularProgressIndicator()),

              if (controller.compressedFile.value != null) ...[
                Text("Compressed Size: ${controller.compressedSize.value}"),
                const SizedBox(height: 20),

                ElevatedButton(onPressed: controller.togglePlayPause, child: Text(controller.isPlaying.value ? "Pause" : "Play")),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

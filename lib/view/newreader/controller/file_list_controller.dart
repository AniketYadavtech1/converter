import 'dart:io';
import 'package:converter/view/newreader/model/file_info_model.dart';
import 'package:converter/view/utill/constants.dart';
import 'package:converter/view/utill/file_utils.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';

class FileListController extends GetxController {
  final String fileType;

  FileListController(this.fileType);

  final RxList<FileInfoModel> files = <FileInfoModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString sortBy = 'date'.obs; // date, name, size

  @override
  void onInit() {
    super.onInit();
    loadFiles();
  }

  Future<void> loadFiles() async {
    isLoading.value = true;
    errorMessage.value = '';
    files.clear();

    try {
      final List<FileInfoModel> tempFiles = [];

      for (String path in AppConstants.searchPaths) {
        final directory = Directory(path);
        if (await directory.exists()) {
          await _scanDirectory(directory, tempFiles);
        }
      }

      files.value = tempFiles;
      sortFiles();
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Error scanning files: $e';
      isLoading.value = false;
    }
  }

  Future<void> _scanDirectory(
      Directory directory,
      List<FileInfoModel> fileList,
      ) async {
    try {
      await for (var entity in directory.list(followLinks: false)) {
        if (_shouldSkipPath(entity.path)) continue;

        if (entity is File) {
          if (_matchesFileType(entity.path)) {
            final stat = await entity.stat();
            fileList.add(FileInfoModel(
              file: entity,
              name: entity.path.split('/').last,
              size: stat.size,
              modifiedDate: stat.modified,
              extension: FileUtils.getFileExtension(entity.path),
            ));
          }
        } else if (entity is Directory) {
          if (_shouldScanSubdirectory(entity.path)) {
            await _scanDirectory(entity, fileList);
          }
        }
      }
    } catch (e) {
      // Skip inaccessible directories
    }
  }

  bool _shouldSkipPath(String path) {
    return AppConstants.skipPatterns.any((pattern) => path.contains(pattern));
  }

  bool _shouldScanSubdirectory(String path) {
    final depth = path.split('/').length;
    return depth < 8;
  }

  bool _matchesFileType(String path) {
    final lowerPath = path.toLowerCase();

    if (fileType == "all") return true;

    final config = AppConstants.fileTypes[fileType];
    if (config == null) return false;

    return config.extensions.any((ext) => lowerPath.endsWith(ext));
  }

  void sortFiles() {
    switch (sortBy.value) {
      case 'name':
        files.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'size':
        files.sort((a, b) => b.size.compareTo(a.size));
        break;
      case 'date':
      default:
        files.sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));
    }
  }

  void changeSortBy(String newSortBy) {
    sortBy.value = newSortBy;
    sortFiles();
  }

  Future<void> openFile(FileInfoModel fileInfo) async {
    try {
      final result = await OpenFile.open(fileInfo.path);

      if (result.type != ResultType.done) {
        Get.snackbar(
          'Error',
          'Unable to open file: ${result.message}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open file: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
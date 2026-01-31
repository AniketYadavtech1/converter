import 'dart:io';

class FileInfoModel {
  final File file;
  final String name;
  final int size;
  final DateTime modifiedDate;
  final String extension;

  FileInfoModel({
    required this.file,
    required this.name,
    required this.size,
    required this.modifiedDate,
    required this.extension,
  });

  String get path => file.path;
}
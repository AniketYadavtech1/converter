import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart'; // Add to pubspec.yaml

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request storage permissions
    if (Platform.isAndroid) {
      final androidVersion = await _getAndroidVersion();

      if (androidVersion >= 30) {
        // Android 11+ requires MANAGE_EXTERNAL_STORAGE
        if (await Permission.manageExternalStorage.isDenied) {
          final status = await Permission.manageExternalStorage.request();
          if (status.isPermanentlyDenied) {
            _showPermissionDialog();
          }
        }
      } else {
        // Android 10 and below
        if (await Permission.storage.isDenied) {
          final status = await Permission.storage.request();
          if (status.isPermanentlyDenied) {
            _showPermissionDialog();
          }
        }
      }
    }
  }

  Future<int> _getAndroidVersion() async {
    // You'll need to add device_info_plus package for this
    // For now, assume Android 11+
    return 30;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Storage permission is required to access files. Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "All Document Reader",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 4,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            _buildFileTypeCard("PDF", Icons.picture_as_pdf, Colors.red, "pdf"),
            _buildFileTypeCard("Word", Icons.description, Colors.blue, "docx"),
            _buildFileTypeCard("Excel", Icons.table_chart, Colors.green, "xlsx"),
            _buildFileTypeCard("PPT", Icons.slideshow, Colors.orange, "pptx"),
            _buildFileTypeCard("TXT", Icons.text_snippet, Colors.grey, "txt"),
            _buildFileTypeCard("Image", Icons.image, Colors.amber, "image"),
            _buildFileTypeCard("All", Icons.folder, Colors.cyan, "all"),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTypeCard(
      String title,
      IconData icon,
      Color color,
      String type,
      ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FileListScreen(fileType: type, typeName: title),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// FILE LIST SCREEN
// ============================================================================

class FileListScreen extends StatefulWidget {
  final String fileType;
  final String typeName;

  const FileListScreen({
    super.key,
    required this.fileType,
    required this.typeName,
  });

  @override
  State<FileListScreen> createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  List<FileInfo> _files = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final List<FileInfo> tempFiles = [];

      // Common storage locations
      final List<String> searchPaths = [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Documents',
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0/Pictures',
        '/storage/emulated/0',
      ];

      for (String path in searchPaths) {
        final directory = Directory(path);
        if (await directory.exists()) {
          await _scanDirectory(directory, tempFiles);
        }
      }

      // Sort by modified date (newest first)
      tempFiles.sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));

      setState(() {
        _files = tempFiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error scanning files: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _scanDirectory(
      Directory directory,
      List<FileInfo> fileList,
      ) async {
    try {
      await for (var entity in directory.list(followLinks: false)) {
        // Skip protected/system folders
        if (_shouldSkipPath(entity.path)) continue;

        if (entity is File) {
          if (_matchesFileType(entity.path)) {
            final stat = await entity.stat();
            fileList.add(FileInfo(
              file: entity,
              name: entity.path.split('/').last,
              size: stat.size,
              modifiedDate: stat.modified,
            ));
          }
        } else if (entity is Directory) {
          // Recursively scan subdirectories (with depth limit)
          if (_shouldScanSubdirectory(entity.path)) {
            await _scanDirectory(entity, fileList);
          }
        }
      }
    } catch (e) {
      // Skip directories we can't access
      debugPrint('Error accessing ${directory.path}: $e');
    }
  }

  bool _shouldSkipPath(String path) {
    final skipPatterns = [
      '/Android/data',
      '/Android/obb',
      '/.',
      '/cache',
      '/thumbnails',
    ];

    return skipPatterns.any((pattern) => path.contains(pattern));
  }

  bool _shouldScanSubdirectory(String path) {
    // Limit scanning depth to avoid performance issues
    final depth = path.split('/').length;
    return depth < 8; // Adjust as needed
  }

  bool _matchesFileType(String path) {
    final lowerPath = path.toLowerCase();

    if (widget.fileType == "all") {
      return true;
    } else if (widget.fileType == "image") {
      return lowerPath.endsWith('.jpg') ||
          lowerPath.endsWith('.jpeg') ||
          lowerPath.endsWith('.png') ||
          lowerPath.endsWith('.webp') ||
          lowerPath.endsWith('.gif');
    } else {
      return lowerPath.endsWith('.${widget.fileType}');
    }
  }

  IconData _getFileIcon(String path) {
    final lowerPath = path.toLowerCase();

    if (lowerPath.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (lowerPath.endsWith('.doc') || lowerPath.endsWith('.docx')) {
      return Icons.description;
    }
    if (lowerPath.endsWith('.xls') || lowerPath.endsWith('.xlsx')) {
      return Icons.table_chart;
    }
    if (lowerPath.endsWith('.ppt') || lowerPath.endsWith('.pptx')) {
      return Icons.slideshow;
    }
    if (lowerPath.endsWith('.txt')) return Icons.text_snippet;
    if (lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.png') ||
        lowerPath.endsWith('.gif') ||
        lowerPath.endsWith('.webp')) {
      return Icons.image;
    }
    return Icons.insert_drive_file;
  }

  Color _getFileColor(String path) {
    final lowerPath = path.toLowerCase();

    if (lowerPath.endsWith('.pdf')) return Colors.red;
    if (lowerPath.endsWith('.doc') || lowerPath.endsWith('.docx')) {
      return Colors.blue;
    }
    if (lowerPath.endsWith('.xls') || lowerPath.endsWith('.xlsx')) {
      return Colors.green;
    }
    if (lowerPath.endsWith('.ppt') || lowerPath.endsWith('.pptx')) {
      return Colors.orange;
    }
    if (lowerPath.endsWith('.txt')) return Colors.grey;
    if (lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.png') ||
        lowerPath.endsWith('.gif') ||
        lowerPath.endsWith('.webp')) {
      return Colors.amber;
    }
    return Colors.cyan;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text("${widget.typeName} Files"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Scanning files...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      )
          : _errorMessage.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFiles,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      )
          : _files.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              "No ${widget.typeName} files found",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Text(
                  '${_files.length} file${_files.length == 1 ? '' : 's'} found',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final fileInfo = _files[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  color: Colors.grey.shade50,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getFileColor(fileInfo.file.path),
                      child: Icon(
                        _getFileIcon(fileInfo.file.path),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      fileInfo.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          fileInfo.file.path,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              _formatFileSize(fileInfo.size),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              ' • ',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Text(
                              _formatDate(fileInfo.modifiedDate),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.white54,
                    ),
                    onTap: () {
                      // TODO: Implement file opening logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening: ${fileInfo.name}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FILE INFO MODEL
// ============================================================================

class FileInfo {
  final File file;
  final String name;
  final int size;
  final DateTime modifiedDate;

  FileInfo({
    required this.file,
    required this.name,
    required this.size,
    required this.modifiedDate,
  });
}
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeController extends GetxController {
  final RxBool isPermissionGranted = false.obs;

  @override
  void onInit() {
    super.onInit();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    try {
      // Request storage permissions
      PermissionStatus status;

      if (await Permission.manageExternalStorage.isGranted) {
        isPermissionGranted.value = true;
        return;
      }

      // Try to request MANAGE_EXTERNAL_STORAGE for Android 11+
      status = await Permission.manageExternalStorage.request();

      if (status.isGranted) {
        isPermissionGranted.value = true;
        return;
      }

      // Fallback to regular storage permission
      status = await Permission.storage.request();

      if (status.isGranted) {
        isPermissionGranted.value = true;
        return;
      }

      // If permanently denied, show dialog
      if (status.isPermanentlyDenied) {
        showPermissionDialog();
      }
    } catch (e) {
      print('Permission error: $e');
    }
  }

  void showPermissionDialog() {
    Get.defaultDialog(
      title: 'Permission Required',
      middleText: 'Storage permission is required to access files. Please enable it in app settings.',
      textConfirm: 'Open Settings',
      textCancel: 'Cancel',
      onConfirm: () {
        openAppSettings();
        Get.back();
      },
    );
  }
}
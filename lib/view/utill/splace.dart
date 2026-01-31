import 'package:converter/view/home/ui/home_converter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  Future<void> checkPermission() async {
    await Future.delayed(const Duration(seconds: 2));
    if (await Permission.storage.isDenied || await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }
    bool granted =
        (await Permission.storage.isDenied ||
        await Permission.manageExternalStorage.isDenied);
    if (granted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Folder Locker App", style: TextStyle(fontSize: 22)),
      ),
    );
  }
}

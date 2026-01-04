import 'package:converter/view/csv/ui/csvView.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Converter")),
      body: Column(
        children: [TextButton(onPressed: () {
          Get.to(CsvViewScreen());
        }, child: Text("Text to pdf"))],
      ),
    );
  }
}

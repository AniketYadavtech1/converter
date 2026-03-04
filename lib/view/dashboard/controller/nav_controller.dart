
import 'package:get/get.dart';

import '../../home/ui/home_converter.dart' show HomePage;


class DashboardController extends GetxController {
  RxInt myCurrentIndex = 0.obs;
  onTabChange(int index) {
    myCurrentIndex.value = index;
  }

  changePage(int index) {
    if (index != myCurrentIndex.value) myCurrentIndex.value = index;
  }

  List pages = [
    const HomePage(),
    const HomePage(),
    const HomePage(),
  ];
}

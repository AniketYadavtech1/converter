import 'package:converter/view/dashboard/controller/nav_controller.dart';
import 'package:converter/view/utill/app_images.dart';
import 'package:converter/view/utill/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class DeliveryServiceBottomBar extends StatelessWidget {
  DeliveryServiceBottomBar({super.key});

  final con = Get.put<DashboardController>(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Stack(
          children: [
            con.pages[con.myCurrentIndex.value],
            Positioned(
              top: 5,
              left: 15,
              right: 15,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(18)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonBottomTab(
                        title: "Order",
                        isSelected: con.myCurrentIndex.value == 0,
                        image: con.myCurrentIndex.value == 0 ? AppImages.selectOrder : AppImages.order,
                        onTap: () => con.changePage(0),
                      ),
                      CommonBottomTab(
                        title: "Service",
                        isSelected: con.myCurrentIndex.value == 1,
                        image: con.myCurrentIndex.value == 1 ? AppImages.selectSummary : AppImages.summary,
                        onTap: () => con.changePage(1),
                      ),
                      CommonBottomTab(
                        title: "Wallet",
                        isSelected: con.myCurrentIndex.value == 2,
                        image: con.myCurrentIndex.value == 2 ? AppImages.selectProfile : AppImages.profiles,
                        onTap: () => con.changePage(2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommonBottomTab extends StatelessWidget {
  final String title;
  final String image;
  final bool isSelected;
  final void Function()? onTap;

  const CommonBottomTab({super.key, required this.title, required this.isSelected, required this.image, this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: isSelected
        ? Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(7)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(image),
                const SizedBox(width: 10),
                isSelected ? Text(title, style: const TextStyle(color: AppColors.white)) : const SizedBox(),
              ],
            ),
          )
        : SvgPicture.asset(image),
  );
}

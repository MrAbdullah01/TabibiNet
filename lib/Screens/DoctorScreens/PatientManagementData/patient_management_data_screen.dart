import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:tabibinet_project/Screens/DoctorScreens/PatientManagementDetailScreen/patient_management_detail_screen.dart';

import '../../../constant.dart';
import '../../../model/res/constant/app_fonts.dart';
import '../../../model/res/constant/app_icons.dart';
import '../../../model/res/widgets/header.dart';
import '../../../model/res/widgets/input_field.dart';
import '../../../model/res/widgets/submit_button.dart';
import '../../../model/res/widgets/text_widget.dart';

class PatientManagementDataScreen extends StatelessWidget {
  PatientManagementDataScreen({super.key});

  final searchC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height1 = 20.0;
    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(
          children: [
            const Header(text: "Patient Management"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: InputField2(
                inputController: searchC,
                hintText: "Find here!",
                prefixIcon: Icons.search,
                suffixIcon: Container(
                  margin: const EdgeInsets.all(14),
                  padding: const EdgeInsets.all(3),
                  height: 20,
                  width: 20,
                  decoration: const BoxDecoration(
                    color: greenColor,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(AppIcons.crossIcon),
                ),
              ),
            ),
            SizedBox(height: height1,),
            Expanded(
                child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: greyColor
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                TextWidget(
                                  text: "Micheal Rickliff", fontSize: 16.sp,
                                  fontWeight: FontWeight.w600, isTextCenter: false,
                                  textColor: textColor, fontFamily: AppFonts.semiBold,),
                                const SizedBox(height: 10,),
                                TextWidget(
                                  text: "ID Number: #33883", fontSize: 14.sp,
                                  fontWeight: FontWeight.w400, isTextCenter: false,
                                  textColor: textColor, ),

                              ],
                            ),
                            SubmitButton(
                              width: 26.w,
                              height: 40,
                              title: "View Detail",
                              textColor: themeColor,
                              bgColor: themeColor.withOpacity(0.1),
                              press: () {
                                Get.to(()=>const PatientManagementDetailScreen());
                              },)
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 15,);
                    },
                    itemCount: 10
                )
            ),
            SizedBox(height: height1,),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: redColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          child: const Icon(Icons.add_rounded,color: bgColor,size: 35,),
          onPressed: () {

        },),
      ),
    );
  }
}

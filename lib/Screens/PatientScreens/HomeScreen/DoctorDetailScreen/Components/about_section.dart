import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:sizer/sizer.dart';
import 'package:tabibinet_project/Screens/PatientScreens/HomeScreen/AppointmentScheduleScreen/appointment_schedule_screen.dart';

import '../../../../../Constants/app_fonts.dart';
import '../../../../../Constants/colors.dart';
import '../../../../../Widgets/submit_button.dart';
import '../../../../../Widgets/text_widget.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
      height: 29.h,
      width: 100.w,
      decoration: const BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: "About Doctor", fontSize: 20.sp,
            fontWeight: FontWeight.w600, isTextCenter: false,
            textColor: textColor, fontFamily: AppFonts.semiBold,),
          SizedBox(
            height: 12.h,
            child: Scrollbar(
              radius: const Radius.circular(10),
              thumbVisibility: true,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextWidget(
                    text: "Dr. Dianne Johnson is a dedicated gynecologist "
                        "committed to women's health and well-being. With "
                        "expertise in obstetrics and gynecology, she provides "
                        "compassionate care, emphasizing preventive measures and"
                        " personalized treatment. Dr. Johnson's approach focuses"
                        " on empowering her patients through education and comprehensive"
                        " medical guidance, ensuring their comfort and confidence throughout"
                        " their healthcare journey.",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400, isTextCenter: false,
                    textColor: textColor,maxLines: 10,)
                ] ,
              ),
            ),
          ),
          const Spacer(),
          SubmitButton(
            title: "Make an appointment",
            press: () {
              Get.to(()=>AppointmentScheduleScreen());
            },)
        ],
      ),
    );
  }
}

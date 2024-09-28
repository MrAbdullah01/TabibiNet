import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:tabibinet_project/Screens/DoctorScreens/AppointmentReminderScreen/appointment_reminder_screen.dart';
import 'package:tabibinet_project/Screens/DoctorScreens/ConsultationScreen/consultation_screen.dart';
import 'package:tabibinet_project/Screens/DoctorScreens/DoctorHomeScreen/Components/quick_access_container.dart';

import '../../../../constant.dart';
import '../../../../model/res/constant/app_icons.dart';

class QuickAccessSection extends StatelessWidget {
  const QuickAccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        QuickAccessContainer(
          onTap: (){
            Get.to(()=> AppointmentReminderScreen());
          },
          text: 'Appointment\nReminders',
          boxColor: purpleColor,
          icon: AppIcons.docIcon,
        ),
        QuickAccessContainer(
          onTap: (){
            Get.to(()=>ConsultationScreen());
          },
          text: 'Teleconsultations',
          boxColor: lightRedColor,
          icon: AppIcons.patientIcon,
        ),
        QuickAccessContainer(
          onTap: (){

          },
          text: 'DocShare',
          boxColor: themeColor,
          icon: AppIcons.docShareIcon,
        ),
      ],
    );
  }
}

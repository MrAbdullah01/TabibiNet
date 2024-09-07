import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../Screens/DoctorScreens/DoctorBottomNavBar/doctor_bottom_navbar.dart';
import '../../Screens/PatientScreens/PatientBottomNavBar/patient_bottom_nav_bar.dart';
import '../../constant.dart';
import '../../global_provider.dart';
import '../../model/res/widgets/toast_msg.dart';
import '../../model/services/FirebaseServices/auth_services.dart';

class SignInProvider extends ChangeNotifier{

  final AuthServices authServices = AuthServices();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final patientProfileProvider = GlobalProviderAccess.patientProfilePro;
  final doctorProfileProvider = GlobalProviderAccess.doctorProfilePro;

  String _userType = "Patient";
  String? _appointmentFrom;
  String? _appointmentTo;
  // String _signInType = "Custom";
  TextEditingController emailC = TextEditingController();
  TextEditingController passwordC = TextEditingController();
  TextEditingController specialityC = TextEditingController();
  TextEditingController specialityDetailC = TextEditingController();
  TextEditingController yearsOfExperienceC = TextEditingController();
  TextEditingController appointmentFeeC = TextEditingController();
  bool _isSignInPasswordShow = true;
  bool _isLoading = false;

  String get userType => _userType;
  String? get appointmentFrom => _appointmentFrom;
  String? get appointmentTo => _appointmentTo;
  // String get signInType => _signInType;
  bool get isSignInPasswordShow => _isSignInPasswordShow;
  bool get isLoading => _isLoading;

  showSignInPassword(){
    _isSignInPasswordShow = !_isSignInPasswordShow;
    notifyListeners();
  }

  setUserType(String userType){
    _userType = userType;
    notifyListeners();
  }

  setAppointmentFrom(String from){
    _appointmentFrom = from;
    notifyListeners();
  }

  setAppointmentTo(String to){
    _appointmentTo = to;
    notifyListeners();
  }

  Future<void> signIn() async {
    _isLoading = true;
    notifyListeners();
    auth.signInWithEmailAndPassword(
        email: emailC.text.toString(),
        password: passwordC.text.toString()
    )
        .then((value) async {
      DocumentReference docRef = fireStore.collection("users").doc(auth.currentUser!.uid);

      // Check if the document exists
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Document exists, check the user type
        final type = docSnapshot.get("userType");
        Get.back(); // Dismiss the dialog

        if (type == "Patient") {
          await patientProfileProvider!.getSelfInfo()
              .whenComplete(() {
            Get.off(() => const PatientBottomNavBar());
          },);
        } else if (type == "Health Professional") {
          doctorProfileProvider!.getSelfInfo()
              .whenComplete(() {
            Get.off(() => const DoctorBottomNavbar());
          },);
        }
      }

      debugPrint('Successfully signed in with Google');
      _isLoading = false;
      notifyListeners();
      log("*********Login********");
      // Get.to(()=>);
    },)
        .onError((error, stackTrace) {
      ToastMsg().toastMsg(error.toString());
      _isLoading = false;
      notifyListeners();
      log("*********$error********");
    },);
  }

  Future<void> signInWithGoogle(BuildContext context, String country) async {
    // Show the loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Sign out from Google to ensure the account selection dialog appears
      await googleSignIn.signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in process, dismiss the dialog
        Get.back();
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential
      UserCredential userCredential = await auth.signInWithCredential(credential);

      // Get a reference to the user's document
      DocumentReference docRef = fireStore.collection("users").doc(auth.currentUser!.uid);

      // Check if the document exists
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Document exists, check the user type
        final type = docSnapshot.get("userType");
        Get.back(); // Dismiss the dialog

        if (type == "Patient") {
          Get.off(() => const PatientBottomNavBar());
        } else if (type == "Health Professional") {
          Get.off(() => const DoctorBottomNavbar());
        }
      } else {
        // Document does not exist, create a new one
        await docRef.set({
          "creationDate": DateTime.now(),
          "userUid": auth.currentUser!.uid,
          "email": auth.currentUser!.email,
          "country": country,
          "name" : auth.currentUser!.displayName,
          "phoneNumber" : auth.currentUser!.phoneNumber ?? "",
          "speciality": specialityC.text.toString(),
          "experience": yearsOfExperienceC.text.toString(),
          "availabilityFrom": _appointmentFrom,
          "availabilityTo": _appointmentTo,
          "appointmentFee": appointmentFeeC.text.toString(),
          "specialityDetail": specialityDetailC.text.toString(),
          "reviews": "0",
          "patients": "0",
          "userType": _userType,
          "accountType": "Google"
        }).whenComplete(() {
          Navigator.of(context).pop(); // Dismiss the dialog
          if (_userType == "Patient") {
            Get.off(() => const PatientBottomNavBar());
          } else {
            Get.off(() => const DoctorBottomNavbar());
          }
        });
      }
      debugPrint('Successfully signed in with Google');
    } catch (e) {
      // Dismiss the dialog in case of error
      Get.back();
      debugPrint("Error: ${e.toString()}");
    }
  }

}


//else {
//         // Document does not exist, create a new one
//         await docRef.set({
//           "userUid": auth.currentUser!.uid,
//           "email": auth.currentUser!.email,
//           "country": country,
//           "userType": _userType,
//           "accountType": _userType
//         }).whenComplete(() {
//           Get.back(); // Dismiss the dialog
//           if (_userType == "Patient") {
//             Get.to(() => const PatientBottomNavBar());
//           } else {
//             Get.to(() => const DoctorBottomNavbar());
//           }
//         });
//       }
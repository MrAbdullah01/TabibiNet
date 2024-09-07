import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tabibinet_project/constant.dart';

class PatientProfileProvider extends ChangeNotifier{

  final TextEditingController nameC = TextEditingController();
  final TextEditingController dateC = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  int? _selectFaq;
  int? _selectFaqCat;
  String _patientName = "";
  String _patientPhone = "";
  File? _image;

  int? get selectFaq => _selectFaq;
  int? get selectFaqCat => _selectFaqCat;
  String get patientName => _patientName;
  String get patientPhone => _patientPhone;
  File? get image => _image;

  Future<void> getSelfInfo() async {
    await fireStore.collection("users").doc(auth.currentUser!.uid).get()
        .then((value) {
          _patientName = value.get("name");
          _patientPhone = value.get("phoneNumber");
          nameC.text = _patientName;
          notifyListeners();
    },);
    log(_patientName);
    log(_patientPhone);
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners();
    }
  }

  void clearImage() {
    _image = null;
    notifyListeners();
  }

  setFaq(index){
    _selectFaq = index;
    notifyListeners();
  }

  setFaqCat(int index){
    _selectFaqCat = index;
    notifyListeners();
  }

}
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tabibinet_project/constant.dart';
import 'package:tabibinet_project/global_provider.dart';
import 'package:tabibinet_project/model/data/fee_information_model.dart';
import 'package:tabibinet_project/model/data/appointment_model.dart';
import 'package:tabibinet_project/model/res/widgets/toast_msg.dart';

import '../../Screens/PatientScreens/StartAppointmentScreen/start_appointment_screen.dart';
import '../../model/services/CloudinaryServices/cloudinary_services.dart';

class PatientAppointmentProvider with ChangeNotifier {

  PatientAppointmentProvider() {
    _filteredTime = List.from(_time); // Initially show all times
  }

  Stream<List<AppointmentModel>> fetchPatientsSingle() {
    log("Doctor id is:: ${auth.currentUser!.uid}");
    return fireStore.collection('appointment')
        .where("patientId",isEqualTo: auth.currentUser!.uid)
        .where("status",isEqualTo: "upcoming")
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AppointmentModel.fromDocumentSnapshot(doc)).toList();
    });
  }

  final CloudinaryService _cloudinaryService = CloudinaryService();

  final profileP = GlobalProviderAccess.profilePro;

  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final problemC = TextEditingController();

  final List<String> _time = [
    "01.00 AM", "02.00 AM", "03.00 AM", "04.00 AM", "05.00 AM", "06.00 AM",
    "07.00 AM", "08.00 AM", "09.00 AM", "10.00 AM", "11.00 AM", "12.00 AM",
    "01.00 PM", "02.00 PM", "03.00 PM", "04.00 PM", "05.00 PM", "06.00 PM",
    "07.00 PM", "08.00 PM", "09.00 PM", "10.00 PM", "11.00 PM", "12.00 PM",
  ];

  String? _doctorId;
  String? _doctorName;
  String? _doctorEmail;
  String? _doctorRating;
  String? _doctorLocation;
  String? _fromTime;
  String? _toTime;
  String? _appointmentTime;
  String? _appointmentDate;
  int? _selectPatientAge;
  String? _selectedGender;
  String? _patientAge;
  //
  bool _isLoading = false;
  String? _uploadedFileUrl;
  //
  int? _selectFeeIndex;
  String _selectFeeType = "";
  String _selectFee = "";
  String _selectFeeId = "";
  String _selectFeeSubTitle = "";
  //
  List<String> _filteredTime = [];
  String? _selectedFile;
  String? _selectedFilePath;


  String? get selectedFilePath => _selectedFilePath;
  String? get selectedFile => _selectedFile;
  List<String> get time => _time;
  List<String> get filteredTime => _filteredTime;
  String? get doctorId => _doctorId;
  String? get doctorName => _doctorName;
  String? get doctorEmail => _doctorEmail;
  String? get doctorRating => _doctorRating;
  String? get doctorLocation => _doctorLocation;
  String? get fromTime => _fromTime;
  String? get toTime => _toTime;
  String? get appointmentTime => _appointmentTime;
  String? get appointmentDate => _appointmentDate;
  String? get selectedGender => _selectedGender;
  String? get patientAge => _patientAge;
  //Fee Variables
  String get selectFeeType => _selectFeeType;
  String get selectFee => _selectFee;
  String get selectFeeId => _selectFeeId;
  String get selectFeeSubTitle => _selectFeeSubTitle;
  int? get selectFeeIndex => _selectFeeIndex;
  //
  int? get selectPatientAge => _selectPatientAge;
  //
  bool get isLoading => _isLoading;
  String? get uploadedFileUrl => _uploadedFileUrl;


  void selectGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void setPatientAge(int index, String age) {
    _selectPatientAge = index;
    _patientAge = age;
    notifyListeners();
  }

  void setSelectedFee(index,feeType,feeAmount,feeId,feeSubTitle){
    _selectFeeIndex = index;
    _selectFee = feeAmount;
    _selectFeeId = feeId;
    _selectFeeSubTitle = feeSubTitle;
    _selectFeeType = feeType;
    log(_selectFeeIndex.toString());
    log(_selectFeeType);
    log(_selectFee);
    notifyListeners();
  }

  void setDoctorDetails(doctorId,doctorName,doctorLocation,doctorRating,doctorEmail){
    _doctorId = doctorId;
    _doctorName = doctorName;
    _doctorEmail = doctorEmail;
    _doctorLocation = doctorLocation;
    _doctorRating = doctorRating;
    log(_doctorId.toString());
    notifyListeners();
  }

  void setAppointmentDate(DateTime date){
    // Format the time using intl
    String formattedDate = DateFormat('EEEE, MMMM d').format(date);
    _appointmentDate = formattedDate;
    log(_appointmentDate.toString());
    notifyListeners();
  }

  void setAppointmentTime(appointmentTime){
    _appointmentTime = appointmentTime;
    log(_appointmentTime.toString());
    notifyListeners();
  }

  void setAvailabilityTime(String? from, String? to) {
    _fromTime = from;
    _toTime = to;
    _filterTimes();
  }

  void _filterTimes() {
    if (_fromTime != null && _toTime != null) {
      int fromIndex = _time.indexOf(_fromTime!);
      int toIndex = _time.indexOf(_toTime!);

      if (fromIndex <= toIndex) {
        _filteredTime = _time.sublist(fromIndex, toIndex + 1);
      }
      notifyListeners();
    }
  }

  Stream<List<FeeInformationModel>> fetchFeeInfo() {
    return fireStore.collection('feeInformation')
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FeeInformationModel.fromDocumentSnapshot(doc)).toList();
    });
  }

  Future<void> sendAppointment(paymentId,amount,clientSecret,amountReceived) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    String fileUrl = "";
     if(_selectedFilePath !=null) {
       fileUrl  = await uploadPdfFile() ?? "";
     }

    await fireStore.collection("appointment").doc(id).set({
      "id" : id,
      "patientId" : auth.currentUser!.uid,
      "doctorId" : _doctorId,
      "doctorName" : _doctorName,
      "doctorEmail" : _doctorEmail,
      "doctorRating" : _doctorRating,
      "doctorLocation" : _doctorLocation,
      "name": profileP!.name,
      "phone": profileP!.phoneNumber,
      "image": profileP!.profileUrl,
      "fees": _selectFee,
      "feesId": _selectFeeId,
      "feesType": _selectFeeType,
      "feeSubTitle": _selectFeeSubTitle,
      "status": "pending",
      "patientName" : nameC.text.toString(),
      "patientEmail" : profileP!.email,
      "patientAge" : _patientAge,
      "patientPhone" : phoneC.text.toString(),
      "patientGender" : _selectedGender,
      "patientProblem" : problemC.text.toString(),
      "appointmentTime" : _appointmentTime,
      "appointmentDate" : _appointmentDate,
      "appointmentPayment" : _selectFee,
      "documentFile" : fileUrl,
      "applyDate" : DateTime.now(),
      "paymentId" : paymentId,
      "amount" : amount,
      "clientSecret" : clientSecret,
      "amountReceived" : amountReceived,
    })
        .whenComplete(() {
          ToastMsg().toastMsg("Appointment Send Successfully!");
      // Get.off(()=>StartAppointmentScreen());
    },);
  }

  Future<String?> uploadPdfFile() async {

    File file = File(_selectedFilePath.toString());

    try {
      _isLoading = true;
      notifyListeners();
      // Create a reference to Firebase Storage
      final storageRef = storage.ref();
      // Create a reference to the file you want to upload
      final fileRef = storageRef.child('reports/${file.uri.pathSegments.last}');

      // Upload the file
      await fileRef.putFile(file);

      // Get the download URL
      final String downloadUrl = await fileRef.getDownloadURL();

      // await addFile(appointmentId, downloadUrl);

      log('File uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      log('Error uploading file: $e');
      return "";
    }
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt'],
      );

      if (result != null) {
        _selectedFilePath = result.files.single.path;
        notifyListeners();
      } else {
        // User canceled the picker
        _selectedFilePath = null;
        notifyListeners();
      }
    } catch (e) {
      log("Error picking file: $e");
    }
  }

  setSelectedFile(file){
    _selectedFile = file;
    notifyListeners();
  }

  void clearSelectedFile() {
    _selectedFilePath = null;
    notifyListeners();
  }

  Future<void> uploadFile() async {
    _isLoading = true;
    notifyListeners();

    try {
      String? url = await _cloudinaryService.uploadFile(File(_selectedFilePath!));
      if (url != null) {
        _uploadedFileUrl = url;
        log("message:: $url");
        notifyListeners();
      }
    } catch (e) {
      log("Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
}
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FCMService {
  List<Color> getPredefinedColors() {
    return [
      Colors.blue,
      Colors.black,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.brown,
      Colors.teal,
      Colors.cyan,
      Colors.indigo,
      Colors.pink,
      Colors.deepPurple,
      Colors.lightGreen,
      Colors.lightBlue,
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.tealAccent,
      Colors.cyanAccent,
      Colors.indigoAccent,
      Colors.pinkAccent,
      Colors.deepOrangeAccent,
      Colors.deepPurpleAccent,
      Colors.lightGreenAccent,
      Colors.lightBlueAccent,
    ];
  }

  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  late final FirebaseMessaging _firebaseMessaging;
  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  static const DarwinNotificationDetails _iOSNotificationDetails =
  DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  Future<void> initialize() async {
    _firebaseMessaging = FirebaseMessaging.instance;
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await setupFlutterNotifications();
    await requestNotificationPermissions();
    configureFirebaseListeners();
  }

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void navigateToChatScreen({
    required String receiverImage,
    required String senderImage,
    required String token,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String comingFrom,
    required String userType,
    required String status,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
      //   builder: (context) => ChatScreen(
      //       receiverImage: receiverImage,
      //       senderImage: senderImage,
      //       token: token,
      //       senderId: senderId,
      //       senderName: senderName,
      //       receiverId: receiverId,
      //       receiverName: receiverName,
      //       comingFrom: comingFrom,
      //       userType: userType,
      //       status: status),
      // ));
    });
  }

  static void navigateToDoctorAppointmentScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
      //   builder: (context) => AppointmentScreenInDoctorApp(),
      // ));
    });
  }

  static void navigateToTalkToSpecialistScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
      //   builder: (context) => TalkToASpecialistScreen(),
      // ));
    });
  }

  Future<void> setupFlutterNotifications() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('launch_background'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveBackgroundNotificationResponse:
      _backgroundNotificationResponse,
      onDidReceiveNotificationResponse: _foregroundNotificationResponse,
    );
  }

  Future<void> requestNotificationPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void configureFirebaseListeners() {
    FirebaseMessaging.onMessage.listen(showNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

  void handleMessage(RemoteMessage message) async {
    if (message.notification?.title?.contains('Message From') == true) {
      final data = message.data;
      navigateToChatScreen(
        receiverImage: data['receiverImage'],
        senderImage: data['senderImage'],
        token: data['token'],
        senderId: data['senderId'],
        senderName: data['senderName'],
        receiverId: data['receiverId'],
        receiverName: data['receiverName'],
        comingFrom: data['comingFrom'],
        userType: data['userType'],
        status: data['status'],
      );
    } else if (message.notification?.title?.contains('Appointment Started') ==
        true) {
      final SharedPreferences preferences =
      await SharedPreferences.getInstance();
      final userType = preferences.getString('userType');
      // final AppointmentProvider appointmentProvider = AppointmentProvider();
      if (userType == null) {
        print('type is null');
      } else {
        if (userType == 'patient') {
          navigateToTalkToSpecialistScreen();
        } else {
          // appointmentProvider.fetchAppointments();
          navigateToDoctorAppointmentScreen();
        }
      }
    }
  }

  void showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: _iOSNotificationDetails,
        ),
      );

      // Check if the dialog should be shown
      if (notification.title!.contains('Hello')) {
        // Ensure the context is valid
        final BuildContext? dialogContext =
            navigatorKey.currentState?.overlay?.context;
        if (dialogContext != null) {
          showDialog(
            context: dialogContext,
            builder: (BuildContext context) {
              List<Color> predefinedColors = getPredefinedColors();
              Color randomColor =
              predefinedColors[Random().nextInt(predefinedColors.length)];
              return AlertDialog(
                backgroundColor: randomColor,
                title: Text(
                  notification.title ?? 'Notification',
                  style: TextStyle(
                     color: Colors.white
                  ),
                ),
                content: Text(
                  notification.body ?? 'You have a new notification.',
                  style: TextStyle(
                     color: Colors.white),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'Close',
                      style: TextStyle(
                           color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          print('Dialog context is null');
        }
      }
    } else {
      print('Received notification is null');
    }
  }

  Future<String> _getAccessToken() async {
    final String jsonString =
    await rootBundle.loadString('android/app/push_messaing.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final serviceAccount = ServiceAccountCredentials.fromJson(jsonData);

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(serviceAccount, scopes);
    final token = client.credentials.accessToken.data;
    client.close();
    return token;
  }

  Future<void> sendNotification(
      String token, String title, String body, String senderId,
      {Map<String, dynamic>? additionalData}) async {
    final accessToken = await _getAccessToken();
    final projectId = await _getProjectId();

    final response = await http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': additionalData,
          },
        },
      ),
    );

    if (response.statusCode == 200) {
      debugPrint("Notification Send");
      saveNotificationInFirebase(
          title: title, subTitle: body, senderId: senderId);
    } else {}
  }

  Future<String> _getProjectId() async {
    final String jsonString =
    await rootBundle.loadString('android/app/push_messaing.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return jsonData['project_id'];
  }

  @pragma('vm:entry-point')
  static void _backgroundNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FCMService().handleMessage(message);
      });
    }
  }

  void _foregroundNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
      handleMessage(message);
    }
  }

  void saveNotificationInFirebase(
      {required String title,
        required String subTitle,
        required String senderId}) {
    // Format the current date as dd-MM-yyyy
    String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    FirebaseFirestore.instance
        .collection("AppConstants.notificationa")
        .doc(senderId)
        .collection("AppConstants.myNotifications")
        .add({
      'title': title,
      'subtitle': subTitle,
      'date': formattedDate, // Save the formatted date
    });
  }

  Future<String?> getDeviceToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print("FCM Device Token: $token");
      return token;
    } catch (e) {
      print("Error getting device token: $e");
      return null;
    }
  }

}
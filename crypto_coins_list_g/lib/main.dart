
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_coins_list/features/auth_service/auth_service.dart';
import 'package:crypto_coins_list/features/notification_service/notification_service.dart';
import 'package:crypto_coins_list/utils.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:crypto_coins_list/locator.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'firebase_options.dart';
import 'crypto_currencies_list_app.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Обработка сообщений, полученных в фоновом режиме
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final Talker talker = TalkerFlutter.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  GetIt.instance.registerSingleton<SharedPreferences>(prefs);
  GetIt.instance.registerSingleton<Talker>(talker);
  late AuthService _authService;

  // Загружаем сохраненный цвет темы
  final String? colorString = prefs.getString('app_color');
  final Color initialColor =
      colorString != null ? Color(int.parse(colorString)) : Colors.blue;

  FlutterError.onError =
      (details) => GetIt.I<Talker>().handle(details.exception, details.stack);

  final Dio dio = Dio();
  dio.interceptors.add(TalkerDioLogger(
    talker: talker,
    settings: const TalkerDioLoggerSettings(printResponseData: false),
  ));

  Bloc.observer = TalkerBlocObserver(talker: talker);

  setupLocator(dio); // Pass dio to setupLocator

  FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  runApp(CryptoCurrenciesListApp(initialColor: initialColor));
}

import 'package:crypto_coins_list/features/ads_features/view/frontend/ad_creation_form.dart';
import 'package:crypto_coins_list/features/auth_service/auth_service.dart';
import 'package:crypto_coins_list/features/settings/bloc/settings_bloc.dart';
import 'package:crypto_coins_list/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:crypto_coins_list/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'features/auth_forgot/view/forgotpass.dart';
import 'features/customNavigationBar/observer/navigator_observer.dart';
import 'features/loading/loading.dart';
import 'features/settings/view/settings_view.dart';
import 'features/single_crypto/view/crypto_coin_screen.dart';
import 'features/changelogs/view/changelogs.dart';

class CryptoCurrenciesListApp extends StatefulWidget {
  final Color initialColor;

  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;

  CryptoCurrenciesListApp({super.key, required this.initialColor}){
    _authService = _getIt.get<AuthService>();
  }

  @override
  State<CryptoCurrenciesListApp> createState() => _CryptoCurrenciesListAppState();
}

class _CryptoCurrenciesListAppState extends State<CryptoCurrenciesListApp> {


  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var messaging = FirebaseMessaging.instance;

    // Запрос разрешений на отправку уведомлений
    messaging.requestPermission();

    // Получение токена устройства (используйте этот токен для отправки уведомлений)
    messaging.getToken().then((token) {
      print("Device Token: $token");
      // Сохраните этот токен для использования при отправке push-уведомлений
    });

    // Обработка сообщений при их получении, когда приложение активно
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message received: ${message.notification?.title} - ${message.notification?.body}");
      // Показ уведомления или обновление UI
    });

    // Обработка сообщений, когда приложение в фоне, но открыто через уведомление
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message clicked: ${message.notification?.title} - ${message.notification?.body}");
      // Обработка клика по уведомлению
    });
  }

  @override
  Widget build(BuildContext context) {
    final MyRouteObserver routeObserver = MyRouteObserver();
    return FutureBuilder<SharedPreferences>(
      future: Future.value(GetIt.I<SharedPreferences>()), // Оборачиваем в Future.value
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading preferences'));
        }

        final preferences = snapshot.data!;

        final GetIt _getIt = GetIt.instance;

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => SettingsBloc(preferences: preferences)..add(LoadSettings()),
            ),
          ],
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              final primaryColor = (state is SettingsLoaded) ? state.themeColor : widget.initialColor;
              final ThemeData OldThemeData = ThemeData(
                iconButtonTheme: const IconButtonThemeData(
                  style: ButtonStyle(
                    foregroundColor: WidgetStatePropertyAll(Colors.white), // Правильное использование
                  ),
                ),
                inputDecorationTheme: const InputDecorationTheme(
                    hintStyle: TextStyle(color: Colors.white),
                    labelStyle: TextStyle(color: Colors.white)
                ),
                iconTheme: const IconThemeData(
                    color: Colors.white
                ),
                textTheme: const TextTheme(
                  displayLarge: TextStyle(color: Colors.white),
                  displayMedium: TextStyle(color: Colors.white),
                  displaySmall: TextStyle(color: Colors.white),
                  headlineLarge: TextStyle(color: Colors.white),
                  headlineMedium: TextStyle(color: Colors.white),
                  headlineSmall: TextStyle(color: Colors.white),
                  labelLarge: TextStyle(color: Colors.white),
                  labelMedium: TextStyle(color: Colors.white),
                  labelSmall: TextStyle(color: Colors.white),
                  titleLarge: TextStyle(color: Colors.white),
                  titleMedium: TextStyle(color: Colors.white),
                  titleSmall: TextStyle(color: Colors.white),
                  bodyLarge: TextStyle(color: Colors.white), // Изменить цвет текста для body
                  bodyMedium: TextStyle(color: Colors.white),
                  bodySmall: TextStyle(color: Colors.white),
                ),
                appBarTheme: const AppBarTheme(
                    centerTitle: true,
                    surfaceTintColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white
                ),
                bottomSheetTheme: const BottomSheetThemeData(
                    backgroundColor: Color(0xff1f1f1f)
                ),
                scaffoldBackgroundColor: const Color.fromARGB(255, 31, 31, 31),
                primaryColor: primaryColor,
                colorScheme: ColorScheme.fromSwatch().copyWith(
                  secondary: const Color(0xFF171717),
                  primary: primaryColor,
                  // brightness: Brightness.dark,
                  onPrimary: Colors.white,
                  onSecondary: Colors.white,
                ),
              );
              final ThemeData NewThemeData = ThemeData(
                iconButtonTheme: const IconButtonThemeData(
                  style: ButtonStyle(
                    overlayColor: WidgetStatePropertyAll(Colors.transparent),
                    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
                  )
                ),
                bottomSheetTheme: const BottomSheetThemeData(
                  backgroundColor: Color(0xFF2C2C2C)
                ),
                primaryColor: primaryColor,
                colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFA600), primary: primaryColor),
                scaffoldBackgroundColor: const Color(0xFF151617),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  centerTitle: true,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(color: Colors.white),
                  titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: false,
                  hintStyle: const TextStyle(color: Colors.white),
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                textTheme: const TextTheme(
                  displayLarge: TextStyle(color: Colors.white),
                  displayMedium: TextStyle(color: Colors.white),
                  displaySmall: TextStyle(color: Colors.white),
                  headlineLarge: TextStyle(color: Colors.white),
                  headlineMedium: TextStyle(color: Colors.white),
                  headlineSmall: TextStyle(color: Colors.white),
                  labelLarge: TextStyle(color: Colors.white),
                  labelMedium: TextStyle(color: Colors.white),
                  labelSmall: TextStyle(color: Colors.white),
                  titleLarge: TextStyle(color: Colors.white),
                  titleMedium: TextStyle(color: Colors.white),
                  titleSmall: TextStyle(color: Colors.white),
                  bodyLarge: TextStyle(color: Colors.white), // Изменить цвет текста для body
                  bodyMedium: TextStyle(color: Colors.white),
                  bodySmall: TextStyle(color: Colors.white),
                ),
                iconTheme: const IconThemeData(
                  color:Color(0xFFFFC700),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC700),
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  backgroundColor: Colors.black,
                  selectedItemColor: Color(0xFFFFC700),
                  unselectedItemColor: Colors.grey,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.orange,
                ),
              );
              return MaterialApp(
                localizationsDelegates: const [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate
                ],
                supportedLocales: S.delegate.supportedLocales,
                navigatorKey: navigatorKey,
                title: 'Miral BIT',
                theme: state is SettingsLoaded && state.useNewTheme ? NewThemeData : OldThemeData,
                routes: {
                  '/': (context) => const CryptoLoadingScreen(),
                  '/coin': (context) => const CryptoCoinScreen(),
                  '/settings': (context) => const SettingsView(),
                  '/changeFont': (context) => const ChangeFontScreen(),
                  '/changelogs': (context) => const ChangeLogs(),
                  '/forgot-password': (context) => const ForgotPasswordScreen(),
                  '/ad-create': (context) => const AdCreationForm(),
                },
                navigatorObservers: [
                  TalkerRouteObserver(GetIt.I<Talker>()),
                  routeObserver
                ],
              );
            },
          ),
        );
      },
    );
  }
}
import 'dart:ui';

import 'package:crypto_coins_list/features/customNavigationBar/view/customnavigationbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../custom_talker/custom_talker.dart';
import '../bloc/settings_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import "package:package_info_plus/package_info_plus.dart";

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {

  Color selectedColor = Colors.blue;
  late SharedPreferences prefs; // Объявляем prefs здесь

  @override
  void initState() {
    super.initState();
    _initPrefs(); // Инициализируем prefs
    context.read<SettingsBloc>().add(LoadSettings());
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance(); // Инициализация prefs
    _getColorFromPrefs(); // Вызываем метод для получения цвета
  }

  Future<void> _getColorFromPrefs() async {
    final colorString = prefs.getString('app_color');
    if (colorString != null) {
      setState(() {
        selectedColor = Color(int.parse(colorString));
      });
      // Обновляем состояние темы в BLoC при загрузке сохраненного цвета
      context.read<SettingsBloc>().add(UpdateTheme(selectedColor));
    }
  }

  Future<void> _setColorToPrefs(Color color) async {
    await prefs.setString('app_color', color.value.toString());
  }

  void pickColor(BuildContext context) async {
    Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) {
        Color tempColor = selectedColor;
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black54 : Colors.black54,
          title: const Text('Select color scheme', style: TextStyle(color: Colors.white),),
          content: SingleChildScrollView(
            child: BlockPicker(
              availableColors: const [
                Colors.yellow,
                Colors.red,
                Colors.blue,
                Colors.teal,
                Colors.green,
                Colors.blueAccent,
                Colors.pink,
                Colors.deepOrange,
                Color(0xFFFFA600),
                Colors.deepOrangeAccent,
                Colors.pinkAccent,
                Colors.lightGreenAccent,
                Colors.indigo,
                Color(0xFFE63946),
                Color(0xFFfb6f92),
                Color(0xFFf50538),
                Color(0xFFb5ea8c),
                Color(0xFF5e87f5),
                Color(0xFF7084E7),
                Color(0xFF4a23d3),
                Color(0xFFb697ff),
                Color(0xFFd53673),
                Color(0xFFf77684),
                Color(0xFF0acc81),
                Color(0xFFa171ff),
                Color(0xFFaaaef7)
              ],
              pickerColor: tempColor,
              onColorChanged: (color) {
                tempColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Select'),
              onPressed: () {
                Navigator.of(context).pop(tempColor);
              },
            ),
          ],
        );
      },
    );

    if (pickedColor != null && pickedColor != selectedColor) {
      setState(() {
        selectedColor = pickedColor;
      });

      // Сохранение выбранного цвета
      await _setColorToPrefs(selectedColor);

      // Обновление темы через Bloc
      context.read<SettingsBloc>().add(UpdateTheme(selectedColor));
    }
  }

  Future<void> checkForUpdates() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    try {
      // Инициализация Firebase Remote Config
      await remoteConfig.setDefaults({
        'latest_version': '1.5', // Значение по умолчанию, если нет доступа к серверу
      });

      await remoteConfig.fetchAndActivate(); // Загружаем и активируем удаленные данные

      // Получаем информацию о текущей версии приложения
      final packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      // Получаем последнюю доступную версию из Remote Config
      String latestVersion = remoteConfig.getString('latest_version');

      if (currentVersion != latestVersion) {
        // Если версии не совпадают, предлагаем обновить
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.black,
              title: const Text("Update Available", style: TextStyle(color: Colors.white),),
              content: const Text(
                "A new version of the app is available. Please update to the latest version for a better experience.",
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Закрыть диалог
                  },
                  child: const Text("Later"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Закрыть диалог
                    // Здесь нужно добавить логику для открытия ссылки на страницу обновлений
                    // Пример для Android: открыть страницу Google Play
                    const url = 'https://t.me/miralbit';
                    launchUrl(Uri.parse(url));
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      } else {
        // Сообщаем, что обновлений нет
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.black,
              title: const Text("No Updates", style: TextStyle(color: Colors.white),),
              content: const Text(
                "Your app is up to date. No new updates are available at this time.",
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Закрыть диалог
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Обрабатываем ошибку
      print('Error fetching remote config: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var pageNames = [
      "CryptoListScreen",
      "SettingsView",
      "CustomTalker"
    ];
    bool isSwitched = false;
    final analytics = FirebaseAnalytics.instance;
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        // Следим за изменениями темы в Bloc
        if (state is ThemeUpdated) {
          setState(() {
            selectedColor = state.color;
          });
        }
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                  centerTitle: true,
                  title: const Text('Settings', style: TextStyle(color: Colors.white),),
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white,),
                ),
              ),
              bottomNavigationBar: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          color: Colors.black.withOpacity(0.1), // Semi-transparent background for glass effect
                        ),
                      ),
                    ),
                  ),
                  NavigationBar(
                    backgroundColor: Colors.transparent,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                    selectedIndex: 1, // Use the updated index
                    onDestinationSelected: (int index) {
                      if (index == 0) {
                        Navigator.of(context).pushNamed('/');
                      } else if (index == 1) {
                        Navigator.of(context).pushNamed('/settings');
                      } else if (index == 2) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CustomTalker(),
                          ),
                        );
                      }

                      analytics.logEvent(
                        name: 'pages_tracked',
                        parameters: {
                          "page_name": pageNames[index],
                          "index": index,
                        },
                      );
                    },
                    destinations: [
                      NavigationDestination(
                        icon: Icon(
                          Icons.home,
                          color: Colors.white,
                        ),
                        label: 'Home',
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Icons.settings_outlined,
                          color: Colors.black,
                        ),
                        label: 'Settings',
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Icons.terminal,
                          color: Colors.white,
                        ),
                        label: 'Logs',
                      ),
                    ],
                  ),
                ],
              ),
              body: ListView(
                children: [
                  BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, state) {
                      return SwitchListTile(
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveThumbColor: Colors.grey,
                        title: const Text(
                          'Display full coin values (in \$)',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: state is SettingsLoaded ? state.displayValues : true, // Default to true if state is not loaded
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(ToggleDisplayValues(value));
                        },
                      );
                    },
                  ),
                  SwitchListTile(
                    activeColor: Theme.of(context).colorScheme.primary,
                    inactiveThumbColor: Colors.grey,
                    title: const Text(
                      'Use v2 Theme (beta)',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: state is SettingsLoaded ? state.useNewTheme : false, // Используем useNewTheme из состояния
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(ToggleTheme(value)); // Теперь используем новое событие ToggleTheme
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.format_paint, color: Colors.white70,),
                    onTap: () {
                      pickColor(context);
                    },
                    title: const Text("Color scheme", style: TextStyle(color: Colors.white),),
                    subtitle: Text("Select color scheme", style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Colors.white70,),
                    title: const Text("About App", style: TextStyle(color: Colors.white),),
                    subtitle: Text("Miral BIT v1.5 by Miral Abbastada", style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),),
                  ),
                  ListTile(
                    leading: const Icon(Icons.telegram, color: Colors.white70,),
                    onTap: () async {
                      final Uri url = Uri.parse("https://t.me/MiralAbbastada");
                      launchUrl(url);
                    },
                    title: const Text("Contact with Miral", style: TextStyle(color: Colors.white),),
                    subtitle: Text("Telegram: https://t.me/MiralAbbastada (@MiralAbbastada)", style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),),
                  ),
                  ListTile(
                    leading: const Icon(Icons.update, color: Colors.white70,),
                    onTap: () async {
                      await checkForUpdates();
                    },
                    title: const Text("Updates", style: TextStyle(color: Colors.white),),
                    subtitle: Text("Check for updates", style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed("/changelogs");
                    },
                    leading: const Icon(Icons.refresh, color: Colors.white70,),
                    title: const Text("Changelogs", style: TextStyle(color: Colors.white),),
                    subtitle: Text("Check all changelogs", style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),),
                  ),
                  ListTile(
                    onTap: (){
                      Navigator.pushNamed((context), "/ad-create");
                    },
                    leading: const Icon(Icons.ads_click, color: Colors.white70,),
                    title: const Text("Place an advertisement", style: TextStyle(color: Colors.white),),
                    subtitle: Text("Advertise your service inside the application (paid)", style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),),
                  ),
                ],
              )
          );
        },
      ),
    );
  }
}


class ChangeFontScreen extends StatefulWidget {
  const ChangeFontScreen({super.key});

  @override
  State<ChangeFontScreen> createState() => _ChangeFontScreenState();
}

class _ChangeFontScreenState extends State<ChangeFontScreen> {
  double sl = 0.3; // Slider value (0.0 to 1.0)
  double fs = 14.0; // Initial font size
  double previousValue = 0.3; // Initialize with sl

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: 100,
        margin: const EdgeInsets.all(20),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.black
            ),
            onPressed: (){},
            child: const Text("Save")
        )
      ),
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        title: const Text("Change message font size", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20,),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "example@mail.com",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.black12,
                    ),
                    child: const Text(
                      "How to download Flutter?",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    "To install flutter, navigate to https://flutter.dev",
                    style: TextStyle(
                      fontSize: fs, // Use fs for font size
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "22:12",
                    style: TextStyle(
                      fontSize: fs, // Use fs for font size
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Slider(
            activeColor: Theme.of(context).colorScheme.primary,
            min: 10.0, // Minimum font size
            max: 30.0, // Maximum font size
            divisions: 20, // More divisions for smoother adjustment
            onChanged: (current) {
              setState(() {
                fs = current; // Directly set fs to the current value
                sl = current; // Update slider value
              });
            },
            value: fs, // Bind slider value to fs
          ),
        ],
      ),
    );
  }
}

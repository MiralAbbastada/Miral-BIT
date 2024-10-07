import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as prov;
import '../../custom_talker/custom_talker.dart';
import '../observer/navigator_observer.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> with RouteAware {
  final user = FirebaseAuth.instance.currentUser;
  final pageNames = ["CryptoListScreen", "SettingsView", "CustomTalker"];
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final MyRouteObserver routeObserver = MyRouteObserver();

  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex; // Initialize currentIndex from widget
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {
      currentIndex = 0; // Reset to the initial screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
          selectedIndex: currentIndex, // Use the updated index
          onDestinationSelected: (int index) {
            setState(() {
              currentIndex = index; // Update the currentIndex
            });

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
                color: currentIndex == 0 ? Colors.black : Colors.white,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.settings_outlined,
                color: currentIndex == 1 ? Colors.black : Colors.white,
              ),
              label: 'Settings',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.terminal,
                color: currentIndex == 2 ? Colors.black : Colors.white,
              ),
              label: 'Logs',
            ),
          ],
        ),
      ],
    );
  }
}

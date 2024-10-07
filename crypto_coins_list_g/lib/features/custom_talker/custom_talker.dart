import 'dart:ui';

import 'package:crypto_coins_list/features/customNavigationBar/view/customnavigationbar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../repositories/crypto_coins_repository/abstract_coins_repo.dart';
import '../../repositories/crypto_coins_repository/models/crypto_coin_model.dart';
import '../crypto_coins_list/bloc/crypto_list_bloc.dart';
import '../functions/functions.dart';

class CustomTalker extends StatefulWidget {
  const CustomTalker({super.key});

  @override
  State<CustomTalker> createState() => _CustomTalkerState();
}

class _CustomTalkerState extends State<CustomTalker> {
  final _cryptoListBloc = CryptoListBloc(GetIt.I<AbstractCoinsRepository>());


  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final String _searchQuery = '';
  List<CryptoCoin> filteredCoins = [];


  @override
  void initState() {
    analytics.setAnalyticsCollectionEnabled(true);
    Functions.updateAvailability();
    super.initState();
    _cryptoListBloc.add(LoadCryptoList());
  }
  var pageNames = [
    "CryptoListScreen",
    "SettingsView",
    "CustomTalker"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TalkerScreen(
        appBarTitle: 'Miral BIT Logs',
        talker: GetIt.I<Talker>(),
        theme: TalkerScreenTheme(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          cardColor: const Color(0xFF1E1E1E),
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
            selectedIndex: 2, // Use the updated index
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
                  color: Colors.white,
                ),
                label: 'Settings',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.terminal,
                  color: Colors.black,
                ),
                label: 'Logs',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
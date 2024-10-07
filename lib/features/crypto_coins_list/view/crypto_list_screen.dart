import 'dart:async';
import 'dart:ui';

import 'package:crypto_coins_list/features/crypto_coins_list/bloc/crypto_list_bloc.dart';
import 'package:crypto_coins_list/features/crypto_coins_list/widgets/widgets.dart';
import 'package:crypto_coins_list/features/settings/bloc/settings_bloc.dart';
import 'package:crypto_coins_list/repositories/crypto_coins_repository/crypto_coins.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Исправлено: используем firebase_ui_auth
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../chat/view/chat.dart';
import '../../customNavigationBar/view/customnavigationbar.dart';
import '../../custom_talker/custom_talker.dart';
import '../../functions/functions.dart';

class CryptoListScreen extends StatefulWidget {
  const CryptoListScreen({super.key, required this.title});

  final String title;

  @override
  State<CryptoListScreen> createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  final _cryptoListBloc = CryptoListBloc(GetIt.I<AbstractCoinsRepository>());

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  String _searchQuery = '';
  List<CryptoCoin> filteredCoins = [];
  bool _isAscending = true;

  @override
  void initState() {
    analytics.setAnalyticsCollectionEnabled(true);
    Functions.updateAvailability();
    super.initState();
    _cryptoListBloc.add(LoadCryptoList());
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _cryptoListBloc.add(LoadCryptoList());
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    var pageNames = ["CryptoListScreen", "SettingsView", "CustomTalker"];
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AuthenticationGate()),
          );
        },
        child: Icon(Icons.chat),
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
            selectedIndex: 0, // Use the updated index
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
                  color: Colors.black,
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
                  color: Colors.white,
                ),
                label: 'Logs',
              ),
            ],
          ),
        ],
      ),
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          setState(() {});
        },
        child: RefreshIndicator(
          onRefresh: () async {
            _cryptoListBloc.add(LoadCryptoList());
          },
          child: BlocBuilder<CryptoListBloc, CryptoListState>(
            bloc: _cryptoListBloc,
            builder: (context, state) {
              if (state is CryptoListLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CryptoListLoaded) {
                filteredCoins = state.coinsList
                    .where((coin) =>
                    coin.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();

                // Сортировка по цене в зависимости от направления
                filteredCoins.sort((a, b) =>
                _isAscending ? a.priceUSD.compareTo(b.priceUSD) : b.priceUSD.compareTo(a.priceUSD));

                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      surfaceTintColor: Colors.transparent,
                      pinned: true,
                      floating: true,
                      snap: true,
                      backgroundColor: const Color(0xFF181818),
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(96),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1d1d1d),
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                ),
                                margin: const EdgeInsets.all(20),
                                child: TextFormField(
                                  onChanged: (query) {
                                    setState(() {
                                      _searchQuery = query;
                                    });
                                  },
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintStyle: const TextStyle(color: Colors.white24),
                                    hintText: "Search crypto by name (example: BTC)",
                                    prefixIcon: const Icon(Icons.search, color: Colors.white,),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 3, color: Theme.of(context).colorScheme.primary),
                                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                    ),
                                    disabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                    ),
                                    errorBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isAscending = !_isAscending;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      centerTitle: true,
                      automaticallyImplyLeading: false,
                      title: const Text(
                        "Miral BIT",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, i) {
                          final coin = filteredCoins[i];
                          return Container(
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: CryptoListTile(coin: coin),
                          );
                        },
                        childCount: filteredCoins.length,
                      ),
                    ),
                  ],
                );
              }
              if (state is CryptoListError) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("TAP! TAP! TAP!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),),
                      SizedBox(height: 20,),
                      ClickableImage(),
                    ],
                  ),
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}

class ClickableImage extends StatefulWidget {
  const ClickableImage({super.key});

  @override
  _ClickableImageState createState() => _ClickableImageState();
}

class _ClickableImageState extends State<ClickableImage> {
  double _imageSize = 150.0; // Изначальный размер
  bool _isTapped = false;
  int counter = 0;

  void _onTap() {
    setState(() {
      _isTapped = !_isTapped;
      _imageSize = _isTapped ? 170.0 : 150.0; // Изменение размера при нажатии
    });

    // Вернуть размер через короткую паузу
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        counter++;
        _imageSize = 150.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("$counter", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
        const SizedBox(height: 20,),
        GestureDetector(
          onTap: _onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200), // Длительность анимации
            width: _imageSize,
            height: _imageSize,
            child: Image.asset("assets/clicker.png"),
          ),
        ),
      ],
    );
  }
}
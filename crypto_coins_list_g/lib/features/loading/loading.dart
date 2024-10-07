import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../crypto_coins_list/view/crypto_list_screen.dart';

class CryptoLoadingScreen extends StatefulWidget {
  const CryptoLoadingScreen({super.key});

  @override
  State<CryptoLoadingScreen> createState() => _CryptoLoadingScreenState();
}

class _CryptoLoadingScreenState extends State<CryptoLoadingScreen> {
  late final SharedPreferences preferences;
  void _loadPreferences() {
    preferences = SharedPreferences.getInstance() as SharedPreferences; // No await needed
  }
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5),
            ()=>Navigator.pushReplacement(context,
            MaterialPageRoute(builder:
                (context) =>
            const CryptoListScreen(title: 'Miral BIT',)
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/icon.png", width: 90, height: 90,),
              const SizedBox(height: 15),
              SizedBox(
                width: 125,
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(50),
                  minHeight: 15.2,
                  color: Theme.of(context).colorScheme.primary,
                  backgroundColor: const Color(0xFF121212),
                )
              ),
            ],
          )
        )
    );
  }
}
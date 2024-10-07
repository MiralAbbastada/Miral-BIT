import 'dart:async';

import 'package:crypto_coins_list/features/ads_features/bloc/ad_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../locator.dart';
import '../../../repositories/crypto_coins_repository/abstract_coins_repo.dart';
import '../../../repositories/crypto_coins_repository/models/crypto_coin_model.dart';
import '../../ads_features/bloc/ad_bloc_event.dart';
import '../../ads_features/view/ads_feature.dart';
import '../../crypto_coins_list/bloc/crypto_list_bloc.dart';

class CryptoCoinScreen extends StatefulWidget{
  const CryptoCoinScreen({super.key});

  @override
  State<CryptoCoinScreen> createState() => CryptoCoins();
}

class CryptoCoins extends State<CryptoCoinScreen> {

  String? coinName;
  CryptoCoin? coin;

  final _cryptoListBloc = CryptoListBloc(GetIt.I<AbstractCoinsRepository>());

  @override
  void initState() {
    // TODO: implement initState
    _refreshValues();
    _cryptoListBloc.add(LoadCryptoList());
    setState(() {});
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _refreshValues();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is CryptoCoin) {
      coin = args; // Assign the received object to coin
      setState(() {});
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(coin?.name ?? '...', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),), // Access name from coin
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white,),
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.black
          ),
          onPressed: (){
            _refreshValues();
          },
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.refresh),
              SizedBox(width: 10.5,),
              Text("Refresh data", style: TextStyle(fontWeight: FontWeight.bold),),
            ],
          ),
        ),
      ),
      body: BlocProvider(
        create: (context) => AdBloc()..add(LoadAdEvent()),
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Color(0xFF131313),
                // border: Border.all(color: Colors.grey, width: 3.0),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              width: MediaQuery.of(context).size.width - 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(coin!.imageURL.toString()),
                  const SizedBox(height: 10,),
                  Text(coin?.name ?? '...', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 30),),
                  const SizedBox(height: 10,),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color:  Color(0xFF131313),
                // border: Border.all(color: Colors.grey, width: 3.0),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: const Text("Additional info", style: TextStyle(fontSize: 15, color: Colors.white),),
            ),
            if (coin != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF131313),
                  // border: Border.all(color: Colors.grey, width: 3.0),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                margin: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Last update", style: TextStyle(fontSize: 15, color: Colors.white)),
                    Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(coin!.lastUpdate), style: const TextStyle(fontSize: 15, color: Colors.white))
                  ],
                ),
              ),
            if (coin != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF131313),
                  // border: Border.all(color: Colors.grey, width: 3.0),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                margin: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Current price", style: TextStyle(fontSize: 15, color: Colors.white)),
                    Text("${coin?.priceUSD.toString()}\$", style: const TextStyle(fontSize: 15, color: Colors.white)),
                  ],
                ),
              ),
            if (coin != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF131313),
                  // border: Border.all(color: Colors.grey, width: 3.0),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                margin: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("High 24 hour", style: TextStyle(fontSize: 15, color: Colors.white)),
                    Text("${coin?.high24Hour.toString()}\$", style: const TextStyle(fontSize: 15, color: Colors.white)),
                  ],
                ),
              ),
            if (coin != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF131313),
                  // border: Border.all(color: Colors.grey, width: 3.0),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                margin: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Low 24 hour", style: TextStyle(fontSize: 15, color: Colors.white)),
                    Text("${coin?.low24Hour.toString()}\$", style: const TextStyle(fontSize: 15, color: Colors.white)),
                  ],
                ),
              ),
            // Obx(()=>Container(child:
            // myContr.isAdLoaded.value ? ConstrainedBox(
            //     constraints: const BoxConstraints(maxHeight: 100, minHeight: 100),
            //     child: AdWidget(ad: myContr.nativeAd!)
            // ) : const SizedBox(
            //   width: 100,
            //   height: 100,
            //   child: Text("Ad not loaded"),
            // ))
            // )
            const AdsWidget(
              backgroundColor: Color(0xFF131313)
            ),
          ],
        ),
      )
    );
  }
  Future<void> _refreshValues() async {
    final coinsRepository = getIt.get<AbstractCoinsRepository>();
    final coinsList = await coinsRepository.getCoinsList();
    try {
      final updatedCoin = coinsList.firstWhere((c) => c.name == coin?.name);
      setState(() {
        coin = updatedCoin;
      });
    } catch (e) {
      // Handle the case where no matching coin is found
      // For example, show a snackbar with an error message
      print(e);
    }
  }
}

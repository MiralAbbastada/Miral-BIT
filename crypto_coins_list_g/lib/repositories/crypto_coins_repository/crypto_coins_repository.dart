import 'package:crypto_coins_list/repositories/crypto_coins_repository/crypto_coins.dart';
import 'package:dio/dio.dart';

class CryptoCoinsRepository implements AbstractCoinsRepository {
  final Dio dio;

  CryptoCoinsRepository({required this.dio});

  @override
  Future<List<CryptoCoin>> getCoinsList() async {
    final response = await dio.get( // Используем переданный dio
        "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC,ETH,LTC,SOL,DOV,TON,BNB,MATIC,NOT,BTT,DOGS,DOT,RENDER,NEXO,NEO,FLOW,CORE,ONDO,BNX,BTG,DASH,LUNA,GAS,FLUX,HMSTR&tsyms=USD&api_key=08fd870aedbefe3e33debf371af44b5e056d95d7a8de06d8e2b528fcc236712b");
    final data = response.data as Map<String, dynamic>;
    final dataRaw = data["RAW"] as Map<String, dynamic>;
    final dataList = dataRaw.entries.map((e) {
      final usdData = (e.value as Map<String, dynamic>)['USD'] as Map<String, dynamic>;
      final price = usdData['PRICE'];
      final imageUrl = usdData["IMAGEURL"];
      final lastUpdate = usdData['LASTUPDATE'];
      final high24Hour = usdData['HIGH24HOUR'];
      final low24Hour = usdData['LOW24HOUR'];

      final lastUpdatedDateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate * 1000);

      return CryptoCoin(
        name: e.key,
        priceUSD: price,
        imageURL: "https://www.cryptocompare.com/$imageUrl",
        lastUpdate: lastUpdatedDateTime,
        high24Hour: high24Hour,
        low24Hour: low24Hour
      );
    }).toList();
    return dataList;
  }
}
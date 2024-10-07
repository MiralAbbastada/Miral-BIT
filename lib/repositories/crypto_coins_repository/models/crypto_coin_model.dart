class CryptoCoin {
  CryptoCoin({
    required this.name,
    required this.priceUSD,
    required this.imageURL,
    required this.lastUpdate, // Change type to DateTime
    required this.high24Hour,
    required this.low24Hour
  });

  final String name;
  final double priceUSD;
  final String imageURL;
  final DateTime lastUpdate; // Change type to DateTime
  final double high24Hour;
  final double low24Hour;
}
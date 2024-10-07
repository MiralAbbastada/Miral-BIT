import 'package:crypto_coins_list/repositories/crypto_coins_repository/models/crypto_coin_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../settings/bloc/settings_bloc.dart';

class CryptoListTile extends StatelessWidget {
  const CryptoListTile({
    super.key,
    required this.coin,
  });

  final CryptoCoin coin;

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsBloc>().state;

    if (settingsState is! SettingsLoaded) {
      return const CircularProgressIndicator(); // Или заглушка
    }

    return ListTile(
      leading: Image.network(coin.imageURL),
      title: Text(
        coin.name,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: settingsState.themeColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        settingsState.displayValues
            ? "${coin.priceUSD}\$"
            : "${coin.priceUSD.toStringAsFixed(2)}\$",
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white70,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
      onTap: () {
        Navigator.of(context).pushNamed('/coin', arguments: coin);
      },
    );
  }
}
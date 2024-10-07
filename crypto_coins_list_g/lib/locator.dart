import 'package:crypto_coins_list/repositories/crypto_coins_repository/abstract_coins_repo.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:crypto_coins_list/repositories/crypto_coins_repository/crypto_coins_repository.dart';

import 'features/auth_service/auth_service.dart';

final getIt = GetIt.instance;

void setupLocator(Dio dio) { // Add Dio as a parameter
  GetIt.I.registerLazySingleton<AbstractCoinsRepository>(
        () => CryptoCoinsRepository(dio: dio), // Pass dio to CryptoCoinsRepository
  );

  GetIt sl = GetIt.instance;

  sl.registerLazySingleton<AuthService>(() => AuthService());
}
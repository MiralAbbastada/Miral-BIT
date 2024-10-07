import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../repositories/crypto_coins_repository/crypto_coins.dart';
part 'crypto_list_event.dart';
part 'crypto_list_state.dart';


class CryptoListBloc extends Bloc<CryptoListEvent, CryptoListState>{
  CryptoListBloc(this.as) : super(CryptoListInitial()){
    on<LoadCryptoList>((event, emit) async{
      try{
        if(state is! CryptoListLoaded){
          emit(CryptoListLoading());
        }
        // throw CryptoListError(exception: Exception()); // только когда тестить
        final cryptoCoinsList = await GetIt.I<AbstractCoinsRepository>().getCoinsList();
        emit(CryptoListLoaded(coinsList: cryptoCoinsList));
      } catch(e, st){
        emit(CryptoListError(exception: e));
        GetIt.I<Talker>().handle(e, st);
      }
    });
  }
  final AbstractCoinsRepository as;
}

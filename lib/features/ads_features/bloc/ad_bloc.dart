import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ad_bloc_event.dart';
import 'ad_bloc_state.dart';

class AdBloc extends Bloc<AdEvent, AdState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdBloc() : super(AdInitial()) {
    on<LoadAdEvent>((event, emit) async {
      emit(AdLoading());
      try {
        // Получение случайной рекламы
        QuerySnapshot snapshot = await _firestore.collection('ads').get();
        if (snapshot.docs.isNotEmpty) {
          final adList = snapshot.docs;
          adList.shuffle();
          final randomAd = adList.first;
          emit(AdLoaded(randomAd.data() as Map<String,dynamic>));
        } else {
          emit(AdEmpty());
        }
      } catch (e) {
        emit(AdError('Failed to load ads: $e'));
      }
    });
  }
}

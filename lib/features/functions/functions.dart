import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';


class Functions {
  static void updateAvailability() {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser; // Get currentUser and check for null

    if (currentUser != null) { // Only proceed if currentUser is not null
      final data = {
        'name': currentUser.displayName ?? currentUser.email,
        'date_time': DateTime.now(),
        'email': currentUser.email,
      };

      try {
        firestore
            .collection("Users")
            .doc(currentUser.uid)
            .set(data);
      } catch (e) {
        GetIt.I<Talker>().error(e);
      }
    }
  }
}
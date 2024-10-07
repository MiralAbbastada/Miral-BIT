import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CrudService{
  static User? user = FirebaseAuth.instance.currentUser;

  static Future saveUserToken(String token) async {
    Map<String, dynamic> data = {
      "email": user!.email,
      "token": token,
    };

    try{
      await FirebaseFirestore.instance.collection("user_data").doc(user!.uid).set(data);

      print("Document added to ${user!.uid}");
    } catch(e){
      print(e.toString());
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';

class FeedbackService {
  static final path = 'feedbacks';
  static final Firestore _db = Firestore.instance;
  static final collection = _db.collection(path);

  static Future<bool> send(String text) async {
    if(text.trim().length < 2) {
      return false;
    }

    FirebaseUser user = await AuthService.singleton().currentUser();

    try {
      await collection.document().setData({
        'text': text,
        'createdAt': DateTime.now(),
        'createdBy': user?.uid,
      });

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }
}

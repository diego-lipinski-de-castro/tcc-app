import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';

class ContactService {
  static final path = 'contacts';
  static final Firestore _db = Firestore.instance;
  static final collection = _db.collection(path);

  static Future<bool> send(String text) async {
    if(text.trim().length < 2) {
      return false;
    }

    FirebaseUser user = await AuthService.singleton().currentUser();

    try {
      await collection.document().setData({
        'name': user?.displayName,
        'email': user?.email,
        'from': user?.email,  
        'to': ['diegocastroh20@gmail.com'],
        'message': {
          'subject': 'Excursões - Contato com o desenvolvedor',
          'text': text
        }
      });

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }
}

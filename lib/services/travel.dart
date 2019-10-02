import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Travel.dart';
import 'auth.dart';

class TravelService {
  static final path = 'travels';
  static final Firestore _db = Firestore.instance;
  static final collection = _db.collection(path);

  Future<bool> update(String docID) async {
    try {
      await collection.document(docID).updateData({'hasMapsDoc': true});

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> delete(String uid) async {
    try {
      await collection.document(uid).delete();
      
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> add(Travel travel) async {
    
    FirebaseUser user = await AuthService().currentUser();

    if (user == null) {
      return false;
    }

    if(user?.phoneNumber == null) {
      return false;
    }

    try {
      await collection.document().setData({
        'title': travel.title,
        'start': travel.start,
        'destiny': travel.destiny,
        'startDateTime': travel.startDateTime,
        'backDateTime': travel.backDateTime,
        'vagas': travel.vagas,
        'price': travel.price,
        'createdAt': DateTime.now(),
        'createdBy': user.uid,
        'phone': user.phoneNumber,
        'titleKey': travel.title.toLowerCase()
      });

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<List<Travel>> search(text) async {
    try {
      text = text.toLowerCase();

      QuerySnapshot snapshot = await collection
          .where('titleKey', isGreaterThanOrEqualTo: text)
          .where('titleKey', isLessThanOrEqualTo: '$text\uf8ff')
          .getDocuments();

      return snapshot.documents
          .map((DocumentSnapshot _doc) => Travel.fromFirestore(_doc))
          .toList();
    } catch (error) {
      print(error);
      return [];
    }
  }

  Future<List<Travel>> getAllByUser() async {
    FirebaseUser user = await AuthService().currentUser();

    if(user == null) {
      return [];
    }

    try {
      QuerySnapshot snapshot =
          await collection.where('createdBy', isEqualTo: user.uid).getDocuments();

      return snapshot.documents
          .map((DocumentSnapshot _doc) => Travel.fromFirestore(_doc))
          .toList();
    } catch (error) {
      print(error);
      return [];
    }
  }
}

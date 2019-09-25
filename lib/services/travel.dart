import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Travel.dart';

class TravelService {
  static final path = 'travels';
  static final Firestore _db = Firestore.instance;
  static final collection = _db.collection(path);

  Future<bool> add() async {
    try {
      await collection.document().setData({
        'title': 'XXX',
        'start': 'Curitiba',
        'destiny': 'Sao Paulo',
        'startDateTime': '21/09/2019 07:00',
        'backDateTime': '22/09/2019 13:00',
        'vagas': '20',
        'price': '100'
      });

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<List<Travel>> search(text) async {
    try {
      QuerySnapshot snapshot =
          await collection.where('title', isLessThan: text).getDocuments();

      return snapshot.documents
          .map((DocumentSnapshot _doc) => Travel.fromFirestore(_doc))
          .toList();
    } catch (error) {
      print(error);
      return [];
    }
  }
}

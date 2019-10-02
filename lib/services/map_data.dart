import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/MapData.dart';

class MapDataService {
  static final path = 'map_data';
  static final Firestore _db = Firestore.instance;
  static final collection = _db.collection(path);

  Future<bool> add(String travelDocID, MapData data) async {
    try {
      print(data);
      await collection.document(travelDocID).setData(data as Map<String, dynamic>);

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<MapData> get(String docID) async {
    try {
      MapData mapData = MapData.fromFirestore(await collection.document(docID).get());

      return mapData;
    } catch (error) {
      print(error);
      return null;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/map_data.dart';

class MapDataService {
  static final path = 'map_data';
  static final Firestore _db = Firestore.instance;
  static final collection = _db.collection(path);

  Future<bool> add(String travelDocID, MapData mapData) async {
    try {
      await collection.document(travelDocID).setData({
        'travelId': mapData.travelId,
        'distance': mapData.distance, 
        'duration': mapData.duration,
        'points': mapData.points,
        'startLat': mapData.startLat,
        'startLng': mapData.startLng,
        'endLat': mapData.endLat,
        'endLng': mapData.endLng,
        'southwestLat': mapData.southwestLat,
        'southwestLng': mapData.southwestLng,
        'northeastLat': mapData.northeastLat,
        'northeastLng': mapData.northeastLng,
      });

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

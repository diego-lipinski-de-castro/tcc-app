import 'package:cloud_firestore/cloud_firestore.dart';

class MapData {
  MapData(
      {this.id,
      this.travelId,
      this.distance,
      this.duration,
      this.points,
      this.startLat,
      this.startLng,
      this.endLat,
      this.endLng,
      this.southwestLat,
      this.southwestLng,
      this.northeastLat,
      this.northeastLng});

  final String id;
  final String travelId;
  final String distance;
  final String duration;
  final String points;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final double southwestLat;
  final double southwestLng;
  final double northeastLat;
  final double northeastLng;

  factory MapData.fromFirestore(DocumentSnapshot documentSnapshot) {
    Map data = documentSnapshot.data;

    return MapData(
        id: documentSnapshot.documentID,
        travelId: data['travelId'] ?? null,
        distance: data['distance'] ?? '',
        duration: data['duration'] ?? '',
        points: data['points'] ?? '',
        startLat: data['startLat'] ?? '',
        startLng: data['startLng'] ?? '',
        endLat: data['endLat'] ?? '',
        endLng: data['endLng'] ?? '',
        southwestLat: data['southwestLat'] ?? '',
        southwestLng: data['southwestLng'] ?? '',
        northeastLat: data['northeastLat'] ?? '',
        northeastLng: data['northeastLng'] ?? '');
  }
}

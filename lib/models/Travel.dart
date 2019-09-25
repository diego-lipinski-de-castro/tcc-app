import 'package:cloud_firestore/cloud_firestore.dart';

class Travel {
  Travel({
    this.id,
    this.title,
    this.start,
    this.destiny,
    this.startDateTime,
    this.backDateTime,
    this.vagas,
    this.price
  });

  final String id;
  final String title;
  final String start;
  final String destiny;
  final String startDateTime;
  final String backDateTime;
  final String vagas;
  final String price;

  factory Travel.fromFirestore(DocumentSnapshot documentSnapshot) {
    Map data = documentSnapshot.data;

    return Travel(
      id: documentSnapshot.documentID,
      title: data['title'] ?? '',
      start: data['start'] ?? '',
      destiny: data['destiny'] ?? '',
      startDateTime: data['startDateTime'] ?? '',
      backDateTime: data['backDateTime'] ?? '',
      vagas: data['vagas'] ?? '',
      price: data['price'] ?? ''
    );
  }
}
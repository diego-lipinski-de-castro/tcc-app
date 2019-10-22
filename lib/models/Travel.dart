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
    this.price,
    this.description,
    this.createdAt,
    this.createdBy,
    this.phone,
    this.titleKey,
    this.hasMapsDoc
  });

  final String id;
  final String title;
  final String start;
  final String destiny;
  final String startDateTime;
  final String backDateTime;
  final String vagas;
  final String price;
  final String description;
  final Timestamp createdAt;
  final String createdBy;
  final String phone;
  final String titleKey;
  final bool hasMapsDoc;

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
      price: data['price'] ?? '',
      description: data['description'] ?? '',
      createdAt: data['createdAt'] ?? '',
      createdBy: data['createdBy'] ?? '',
      phone: data['phone'] ?? '',
      titleKey: data['titleKey'] ?? '',
      hasMapsDoc: data['hasMapsDoc'] ?? false,
    );
  }

  bool isValid() {
    if(
      this.title.trim() == ''
      || this.start.trim() == ''
      || this.destiny.trim() == ''
      || this.startDateTime.trim() == ''
      || this.backDateTime.trim() == ''
      || this.vagas.trim() == ''
      || this.price.trim() == ''
    ) {
      return false;
    }

    return true;
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {
  final String id;
  final String code;
  final String description;
  final double discountPercent;
  final double maxDiscount;
  final DateTime startDate;
  final DateTime endDate;
  final int quantity;

  VoucherModel({
    required this.id,
    required this.code,
    required this.description,
    required this.discountPercent,
    required this.maxDiscount,
    required this.startDate,
    required this.endDate,
    required this.quantity,
  });

  factory VoucherModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VoucherModel(
      id: doc.id,
      code: data['code'],
      description: data['description'],
      discountPercent: (data['discountPercent'] ?? 0).toDouble(),
      maxDiscount: (data['maxDiscount'] ?? 0).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      quantity: data['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'description': description,
      'discountPercent': discountPercent,
      'maxDiscount': maxDiscount,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'quantity': quantity,
    };
  }
}

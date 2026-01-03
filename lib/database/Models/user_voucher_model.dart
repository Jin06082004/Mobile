import 'package:cloud_firestore/cloud_firestore.dart';

class UserVoucherModel {
  final String id;
  final String userId;
  final String voucherId;
  final DateTime usedAt;

  UserVoucherModel({
    required this.id,
    required this.userId,
    required this.voucherId,
    required this.usedAt,
    required String bookingId,
  });

  factory UserVoucherModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserVoucherModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      voucherId: data['voucherId'] ?? '',
      usedAt: (data['usedAt'] as Timestamp).toDate(),
      bookingId: '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'voucherId': voucherId,
      'usedAt': Timestamp.fromDate(usedAt),
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class AIChatMessageModel {
  final String id;
  final String userId;
  final String message;
  final bool isUser;
  final DateTime createdAt;

  AIChatMessageModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.isUser,
    required this.createdAt,
  });

  factory AIChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AIChatMessageModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      message: data['message'] ?? '',
      isUser: data['isUser'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'message': message,
      'isUser': isUser,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

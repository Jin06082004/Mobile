import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../database/Models/voucher_model.dart';

class AdminVoucherScreen extends StatelessWidget {
  const AdminVoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Voucher')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Thêm chức năng thêm voucher mới
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('vouchers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final vouchers = snapshot.data!.docs
              .map((doc) => VoucherModel.fromFirestore(doc))
              .toList();
          if (vouchers.isEmpty) {
            return const Center(child: Text('Chưa có voucher nào'));
          }
          return ListView.builder(
            itemCount: vouchers.length,
            itemBuilder: (context, index) {
              final voucher = vouchers[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(voucher.code),
                  subtitle: Text(
                    '${voucher.description}\nGiảm ${voucher.discountPercent}% tối đa ${voucher.maxDiscount}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('vouchers')
                          .doc(voucher.id)
                          .delete();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/Models/booking_model.dart' hide PaymentStatus;
import '../database/Models/room_model.dart';
import '../database/Models/payment_model.dart';
import '../database/Models/user_model.dart';
import '../database/Models/voucher_model.dart';
import '../database/Models/user_voucher_model.dart';
import '../services/email_service.dart';
import 'home_screen.dart';

class PaymentScreen extends StatefulWidget {
  final BookingModel booking;
  final RoomModel room;

  const PaymentScreen({super.key, required this.booking, required this.room});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String formatVND(num value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }

  PaymentMethod _selectedMethod = PaymentMethod.cash;
  bool _isProcessing = false;
  TextEditingController _voucherController = TextEditingController();
  VoucherModel? _appliedVoucher;
  double _discountAmount = 0;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final paymentRef = FirebaseFirestore.instance
          .collection('payments')
          .doc();

      // Tính toán giá cuối cùng
      final double finalAmount = (widget.booking.totalPrice - _discountAmount)
          .clamp(0, double.infinity);

      // Create payment record
      final payment = PaymentModel(
        id: paymentRef.id,
        bookingId: widget.booking.id,
        userId: userId,
        amount: finalAmount,
        method: _selectedMethod,
        status: PaymentStatus.completed,
        transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      await paymentRef.set(payment.toFirestore());

      // Nếu có voucher được áp dụng, lưu vào user_vouchers và giảm số lượng voucher
      if (_appliedVoucher != null) {
        final userVoucher = UserVoucherModel(
          userId: userId,
          voucherId: _appliedVoucher!.id,
          bookingId: widget.booking.id,
          usedAt: DateTime.now(),
          id: '',
        );
        await FirebaseFirestore.instance
            .collection('user_vouchers')
            .add(userVoucher.toFirestore());

        // Giảm số lượng voucher
        final voucherRef = FirebaseFirestore.instance
            .collection('vouchers')
            .doc(_appliedVoucher!.id);
        await voucherRef.update({'quantity': FieldValue.increment(-1)});
      }

      // Lấy thông tin user để gửi email
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final user = UserModel.fromFirestore(userDoc);
        EmailService.sendPaymentConfirmationEmail(
          recipientEmail: user.email,
          fullName: user.fullName,
          roomName: widget.room.name,
          totalPrice: BookingModel.formatPrice(
            finalAmount,
          ), // Đúng số tiền đã thanh toán
          transactionId: payment.transactionId ?? 'N/A',
        ).catchError((e) {
          print('Lỗi gửi email: $e');
        });
      }

      if (mounted) {
        setState(() {}); // Cập nhật lại UI với giá mới
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text('Thành công!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thanh toán thành công!'),
                const SizedBox(height: 8),
                Text(
                  'Số tiền đã thanh toán: ${formatVND(finalAmount)} VNĐ',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Đặt phòng của bạn đã được xác nhận.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thanh toán',
          style: TextStyle(
            color: Color(0xFF667eea),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF667eea)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Booking Summary
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 6,
              shadowColor: const Color(0xFF667eea).withOpacity(0.08),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tóm tắt đặt phòng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF667eea),
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        if (widget.room.images.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.room.images.first,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.hotel),
                              ),
                            ),
                          ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.room.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF667eea),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _InfoRow(
                                label: 'Nhận phòng',
                                value:
                                    '${widget.booking.checkInDate.day}/${widget.booking.checkInDate.month}/${widget.booking.checkInDate.year}',
                              ),
                              const SizedBox(height: 4),
                              _InfoRow(
                                label: 'Trả phòng',
                                value:
                                    '${widget.booking.checkOutDate.day}/${widget.booking.checkOutDate.month}/${widget.booking.checkOutDate.year}',
                              ),
                              const SizedBox(height: 4),
                              _InfoRow(
                                label: 'Số khách',
                                value: '${widget.booking.numberOfGuests}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Payment Method Selection
            const Text(
              'Phương thức thanh toán',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 14),
            ...PaymentMethod.values.map((method) {
              return _PaymentMethodTile(
                method: method,
                isSelected: _selectedMethod == method,
                onTap: () {
                  setState(() => _selectedMethod = method);
                },
              );
            }),
            const SizedBox(height: 28),
            // Price Summary
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFe0e7ff), Color(0xFFf3e8ff)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF667eea).withOpacity(0.15)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${widget.room.formattedPrice} x ${widget.booking.nights} đêm',
                          style: const TextStyle(
                            color: Color(0xFF667eea),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          formatVND(widget.booking.totalPrice) + ' VNĐ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF764ba2),
                          ),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  if (_discountAmount > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Giảm giá voucher',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '-${formatVND(_discountAmount)} VNĐ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Số tiền phải thanh toán',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667eea),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          '${formatVND((widget.booking.totalPrice - _discountAmount).clamp(0, double.infinity))} VNĐ',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF764ba2),
                          ),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Voucher Code Input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mã voucher',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _voucherController,
                        decoration: const InputDecoration(
                          hintText: 'Nhập mã voucher',
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final code = _voucherController.text.trim();
                        final query = await FirebaseFirestore.instance
                            .collection('vouchers')
                            .where('code', isEqualTo: code)
                            .where('endDate', isGreaterThan: DateTime.now())
                            .limit(1)
                            .get();
                        if (query.docs.isNotEmpty) {
                          final voucher = VoucherModel.fromFirestore(
                            query.docs.first,
                          );
                          setState(() {
                            _appliedVoucher = voucher;
                            _discountAmount =
                                (widget.booking.totalPrice *
                                        voucher.discountPercent /
                                        100)
                                    .clamp(0, voucher.maxDiscount);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Áp dụng thành công voucher!'),
                            ),
                          );
                        } else {
                          setState(() {
                            _appliedVoucher = null;
                            _discountAmount = 0;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Voucher không hợp lệ')),
                          );
                        }
                      },
                      child: const Text('Áp dụng'),
                    ),
                  ],
                ),
                if (_appliedVoucher != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Giảm giá: -${_discountAmount.toStringAsFixed(0)} VNĐ',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            // Payment Button
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: _isProcessing
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Xác nhận thanh toán',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Security Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Thông tin thanh toán của bạn được bảo mật',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? const Color(0xFF667eea) : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(14),
        color: isSelected ? const Color(0xFFe0e7ff) : null,
      ),
      child: ListTile(
        leading: Icon(
          _getMethodIcon(method),
          color: isSelected ? const Color(0xFF764ba2) : Colors.grey[600],
        ),
        title: Text(
          _getMethodLabel(method),
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF667eea) : null,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xFF667eea))
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  IconData _getMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.debitCard:
        return Icons.credit_card;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.momo:
        return Icons.payment;
      case PaymentMethod.zalopay:
        return Icons.payment;
    }
  }

  String _getMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Tiền mặt';
      case PaymentMethod.creditCard:
        return 'Thẻ tín dụng';
      case PaymentMethod.debitCard:
        return 'Thẻ ghi nợ';
      case PaymentMethod.bankTransfer:
        return 'Chuyển khoản ngân hàng';
      case PaymentMethod.momo:
        return 'Ví MoMo';
      case PaymentMethod.zalopay:
        return 'Ví ZaloPay';
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'Models/room_model.dart';
import 'Models/voucher_model.dart';

class SeedData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Seed sample rooms
  Future<void> seedRooms() async {
    final rooms = [
      RoomModel(
        id: 'room1',
        name: 'Phòng Deluxe Hướng Biển',
        description:
            'Phòng cao cấp với view biển tuyệt đẹp. Phòng rộng 35m2 với đầy đủ tiện nghi hiện đại, ban công riêng nhìn ra biển.',
        type: RoomType.deluxe,
        pricePerNight: 1500000,
        maxGuests: 2,
        bedCount: 1,
        bathroomCount: 1,
        area: 35,
        amenities: [
          'WiFi miễn phí',
          'Điều hòa',
          'TV màn hình phẳng',
          'Minibar',
          'Két an toàn',
          'Bồn tắm',
          'View biển',
        ],
        images: [
          'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800',
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
        ],
        status: RoomStatus.available,
        floor: 'Tầng 5',
        createdAt: DateTime.now(),
      ),
      RoomModel(
        id: 'room2',
        name: 'Phòng Standard Double',
        description:
            'Phòng tiêu chuẩn với 2 giường đơn, phù hợp cho gia đình hoặc bạn bè. Diện tích 28m2, đầy đủ tiện nghi cơ bản.',
        type: RoomType.standard,
        pricePerNight: 800000,
        maxGuests: 3,
        bedCount: 2,
        bathroomCount: 1,
        area: 28,
        amenities: [
          'WiFi miễn phí',
          'Điều hòa',
          'TV',
          'Tủ lạnh',
          'Phòng tắm đứng',
        ],
        images: [
          'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
          'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=800',
        ],
        status: RoomStatus.available,
        floor: 'Tầng 3',
        createdAt: DateTime.now(),
      ),
      RoomModel(
        id: 'room3',
        name: 'Suite Tổng Thống',
        description:
            'Suite sang trọng bậc nhất với 2 phòng ngủ, phòng khách riêng biệt. Diện tích 80m2 với tầm nhìn panorama tuyệt đẹp.',
        type: RoomType.presidential,
        pricePerNight: 5000000,
        maxGuests: 4,
        bedCount: 2,
        bathroomCount: 2,
        area: 80,
        amenities: [
          'WiFi cao tốc',
          'Điều hòa trung tâm',
          'TV Smart 65 inch',
          'Minibar cao cấp',
          'Két an toàn',
          'Bồn tắm Jacuzzi',
          'Phòng khách riêng',
          'Ban công lớn',
          'View 360 độ',
          'Butler service',
        ],
        images: [
          'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800',
          'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800',
          'https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=800',
        ],
        status: RoomStatus.available,
        floor: 'Penthouse',
        createdAt: DateTime.now(),
      ),
      RoomModel(
        id: 'room4',
        name: 'Phòng Family Suite',
        description:
            'Phòng suite gia đình rộng rãi với 2 phòng ngủ kết nối. Lý tưởng cho gia đình có trẻ em. Diện tích 55m2.',
        type: RoomType.suite,
        pricePerNight: 2800000,
        maxGuests: 5,
        bedCount: 3,
        bathroomCount: 2,
        area: 55,
        amenities: [
          'WiFi miễn phí',
          'Điều hòa',
          'TV 2 phòng',
          'Minibar',
          'Két an toàn',
          'Bồn tắm + Phòng tắm đứng',
          'Khu vực sinh hoạt chung',
          'Giường phụ cho trẻ em',
        ],
        images: [
          'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800',
          'https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800',
        ],
        status: RoomStatus.available,
        floor: 'Tầng 7',
        createdAt: DateTime.now(),
      ),
      RoomModel(
        id: 'room5',
        name: 'Phòng Standard Single',
        description:
            'Phòng đơn tiêu chuẩn phù hợp cho khách công tác. Nhỏ gọn, tiện nghi, diện tích 22m2.',
        type: RoomType.standard,
        pricePerNight: 600000,
        maxGuests: 1,
        bedCount: 1,
        bathroomCount: 1,
        area: 22,
        amenities: [
          'WiFi miễn phí',
          'Điều hòa',
          'TV',
          'Bàn làm việc',
          'Phòng tắm đứng',
          'Tủ quần áo',
        ],
        images: [
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800',
        ],
        status: RoomStatus.available,
        floor: 'Tầng 2',
        createdAt: DateTime.now(),
      ),
      RoomModel(
        id: 'room6',
        name: 'Deluxe Twin Garden View',
        description:
            'Phòng cao cấp 2 giường đơn hướng vườn. Không gian yên tĩnh với view vườn xanh mát. Diện tích 32m2.',
        type: RoomType.deluxe,
        pricePerNight: 1200000,
        maxGuests: 2,
        bedCount: 2,
        bathroomCount: 1,
        area: 32,
        amenities: [
          'WiFi miễn phí',
          'Điều hòa',
          'TV màn hình phẳng',
          'Minibar',
          'Két an toàn',
          'Bồn tắm',
          'View vườn',
          'Ban công',
        ],
        images: [
          'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800',
          'https://images.unsplash.com/photo-1560185127-6ed189bf02f4?w=800',
        ],
        status: RoomStatus.available,
        floor: 'Tầng 4',
        createdAt: DateTime.now(),
      ),
    ];

    for (var room in rooms) {
      await _firestore.collection('rooms').doc(room.id).set(room.toFirestore());
    }
  }

  // Seed sample vouchers
  Future<void> seedVouchers() async {
    String formatVND(num value) {
      return value
          .toStringAsFixed(0)
          .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
    }

    final vouchers = [
      VoucherModel(
        id: 'voucher1',
        code: 'WELCOME10',
        description: 'Giảm 10% cho đơn đầu tiên, tối đa ${formatVND(200000)}đ',
        discountPercent: 10,
        maxDiscount: 200000,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 60)),
        quantity: 100,
      ),
      VoucherModel(
        id: 'voucher2',
        code: 'SUMMER20',
        description: 'Ưu đãi hè: Giảm 20% tối đa ${formatVND(300000)}đ',
        discountPercent: 20,
        maxDiscount: 300000,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 90)),
        quantity: 50,
      ),
      VoucherModel(
        id: 'voucher3',
        code: 'FAMILY15',
        description:
            'Giảm 15% cho phòng Family Suite, tối đa ${formatVND(250000)}đ',
        discountPercent: 15,
        maxDiscount: 250000,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 45)),
        quantity: 30,
      ),
      VoucherModel(
        id: 'voucher4',
        code: 'DELUXE5',
        description: 'Giảm 5% cho phòng Deluxe, tối đa ${formatVND(100000)}đ',
        discountPercent: 5,
        maxDiscount: 100000,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 30)),
        quantity: 40,
      ),
      VoucherModel(
        id: 'voucher5',
        code: 'NEWYEAR50',
        description: 'Mừng năm mới: Giảm 50% tối đa ${formatVND(500000)}đ',
        discountPercent: 50,
        maxDiscount: 500000,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 10)),
        quantity: 10,
      ),
    ];

    for (var voucher in vouchers) {
      await _firestore
          .collection('vouchers')
          .doc(voucher.id)
          .set(voucher.toFirestore());
    }
  }

  // Seed all data
  Future<void> seedAll() async {
    try {
      print('🌱 Bắt đầu seed dữ liệu...');

      print('📦 Đang thêm phòng...');
      await seedRooms();
      print('✅ Đã thêm ${6} phòng');

      print('🎟️ Đang thêm voucher...');
      await seedVouchers();
      print('✅ Đã thêm ${5} voucher');

      print('🎉 Hoàn thành seed dữ liệu!');
    } catch (e) {
      print('❌ Lỗi khi seed dữ liệu: $e');
      rethrow;
    }
  }

  // Clear all data (use with caution!)
  Future<void> clearAllData() async {
    try {
      print('🗑️ Đang xóa dữ liệu cũ...');

      // Delete all rooms
      final roomsSnapshot = await _firestore.collection('rooms').get();
      for (var doc in roomsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete all vouchers
      final vouchersSnapshot = await _firestore.collection('vouchers').get();
      for (var doc in vouchersSnapshot.docs) {
        await doc.reference.delete();
      }

      print('✅ Đã xóa dữ liệu');
    } catch (e) {
      print('❌ Lỗi khi xóa dữ liệu: $e');
      rethrow;
    }
  }
}

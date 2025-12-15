import 'package:cloud_firestore/cloud_firestore.dart';
import 'Models/room_model.dart';
import 'Models/booking_model.dart' hide PaymentStatus;
import 'Models/user_model.dart';
import 'Models/payment_model.dart';
import 'Models/review_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DatabaseHelper._init();

  // ==================== ROOMS ====================

  /// Get all available rooms
  Stream<List<RoomModel>> getRooms() {
    return _firestore
        .collection('rooms')
        .where('status', isEqualTo: RoomStatus.available.name)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => RoomModel.fromFirestore(doc)).toList(),
        );
  }

  /// Get room by ID
  Future<RoomModel?> getRoomById(String roomId) async {
    try {
      final doc = await _firestore.collection('rooms').doc(roomId).get();
      if (doc.exists) {
        return RoomModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting room: $e');
      return null;
    }
  }

  /// Add new room
  Future<void> addRoom(RoomModel room) async {
    await _firestore.collection('rooms').doc(room.id).set(room.toFirestore());
  }

  /// Update room
  Future<void> updateRoom(RoomModel room) async {
    await _firestore
        .collection('rooms')
        .doc(room.id)
        .update(room.toFirestore());
  }

  /// Delete room
  Future<void> deleteRoom(String roomId) async {
    await _firestore.collection('rooms').doc(roomId).delete();
  }

  /// Search rooms by name or type
  Stream<List<RoomModel>> searchRooms(String query, {RoomType? type}) {
    Query<Map<String, dynamic>> queryRef = _firestore.collection('rooms');

    if (type != null) {
      queryRef = queryRef.where('type', isEqualTo: type.name);
    }

    return queryRef.snapshots().map((snapshot) {
      final rooms = snapshot.docs
          .map((doc) => RoomModel.fromFirestore(doc))
          .toList();
      if (query.isEmpty) return rooms;

      return rooms
          .where(
            (room) =>
                room.name.toLowerCase().contains(query.toLowerCase()) ||
                room.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  // ==================== USERS ====================

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Get user stream
  Stream<UserModel?> getUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Add or update user
  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toFirestore());
  }

  /// Update user
  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .update(user.toFirestore());
  }

  // ==================== BOOKINGS ====================

  /// Get bookings by user ID
  Stream<List<BookingModel>> getUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList();
          bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return bookings;
        });
  }

  /// Get bookings by status
  Stream<List<BookingModel>> getBookingsByStatus(
    String userId,
    List<BookingStatus> statuses,
  ) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: statuses.map((s) => s.name).toList())
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList();
          bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return bookings;
        });
  }

  /// Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists) {
        return BookingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting booking: $e');
      return null;
    }
  }

  /// Create booking
  Future<String> createBooking(BookingModel booking) async {
    final docRef = await _firestore
        .collection('bookings')
        .add(booking.toFirestore());
    return docRef.id;
  }

  /// Update booking
  Future<void> updateBooking(BookingModel booking) async {
    await _firestore
        .collection('bookings')
        .doc(booking.id)
        .update(booking.toFirestore());
  }

  /// Cancel booking
  Future<void> cancelBooking(String bookingId, String reason) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.cancelled.name,
      'cancelledAt': Timestamp.now(),
      'cancellationReason': reason,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Check room availability
  Future<bool> isRoomAvailable(
    String roomId,
    DateTime checkIn,
    DateTime checkOut,
  ) async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('roomId', isEqualTo: roomId)
        .where(
          'status',
          whereIn: [BookingStatus.confirmed.name, BookingStatus.pending.name],
        )
        .get();

    for (var doc in snapshot.docs) {
      final booking = BookingModel.fromFirestore(doc);
      // Check if dates overlap
      if (checkIn.isBefore(booking.checkOutDate) &&
          checkOut.isAfter(booking.checkInDate)) {
        return false;
      }
    }
    return true;
  }

  // ==================== PAYMENTS ====================

  /// Get payment by booking ID
  Future<PaymentModel?> getPaymentByBookingId(String bookingId) async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return PaymentModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting payment: $e');
      return null;
    }
  }

  /// Create payment
  Future<String> createPayment(PaymentModel payment) async {
    final docRef = await _firestore
        .collection('payments')
        .add(payment.toFirestore());
    return docRef.id;
  }

  /// Update payment status
  Future<void> updatePaymentStatus(
    String paymentId,
    PaymentStatus status,
  ) async {
    await _firestore.collection('payments').doc(paymentId).update({
      'status': status.name,
      'completedAt': status == PaymentStatus.completed ? Timestamp.now() : null,
    });
  }

  // ==================== REVIEWS ====================

  /// Get reviews by room ID
  Stream<List<ReviewModel>> getRoomReviews(String roomId) {
    return _firestore
        .collection('reviews')
        .where('roomId', isEqualTo: roomId)
        .snapshots()
        .map((snapshot) {
          final reviews = snapshot.docs
              .map((doc) => ReviewModel.fromFirestore(doc))
              .toList();
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return reviews;
        });
  }

  /// Check if user has reviewed a booking
  Future<bool> hasUserReviewedBooking(String userId, String bookingId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Create review
  Future<String> createReview(ReviewModel review) async {
    final docRef = await _firestore
        .collection('reviews')
        .add(review.toFirestore());
    return docRef.id;
  }

  /// Update review
  Future<void> updateReview(ReviewModel review) async {
    await _firestore
        .collection('reviews')
        .doc(review.id)
        .update(review.toFirestore());
  }

  /// Get average rating for a room
  Future<double> getRoomAverageRating(String roomId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('roomId', isEqualTo: roomId)
        .get();

    if (snapshot.docs.isEmpty) return 0.0;

    double total = 0;
    for (var doc in snapshot.docs) {
      final review = ReviewModel.fromFirestore(doc);
      total += review.rating;
    }

    return total / snapshot.docs.length;
  }

  // ==================== STATISTICS ====================

  /// Get total bookings count for user
  Future<int> getUserBookingsCount(String userId) async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  /// Get total revenue from bookings
  Future<double> getTotalRevenue() async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('paymentStatus', isEqualTo: PaymentStatus.completed.name)
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      final booking = BookingModel.fromFirestore(doc);
      total += booking.totalPrice;
    }

    return total;
  }
}

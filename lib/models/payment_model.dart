import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String paymentId;
  final String bookingId;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime paymentDate;

  PaymentModel({
    required this.paymentId, 
    required this.bookingId, 
    required this.amount, 
    required this.paymentMethod, 
    required this.status, 
    required this.paymentDate,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PaymentModel(
      paymentId: doc.id,
      bookingId: data['booking_id'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      paymentMethod: data['payment_method'] ?? 'wallet',
      status: data['status'] ?? 'pending',
      paymentDate: (data['payment_date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "booking_id": bookingId,
      "amount": amount,
      "payment_method": paymentMethod,
      "status": status,
      "payment_date": Timestamp.fromDate(paymentDate),
    };
  }
}
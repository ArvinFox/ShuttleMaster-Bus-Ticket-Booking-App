import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  // Using Android Emulator
  static const String backendUrl =
      'http://10.0.2.2:3000'; // IP for Android Emulator

  Future<String> createPaymentIntent(int amount) async {
    final response = await http.post(
      Uri.parse('$backendUrl/create-payment-intent'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'amount': amount}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['clientSecret'];
    } else {
      throw Exception('Failed to create payment intent');
    }
  }
}

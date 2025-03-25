import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';
import 'package:flutter/services.dart';
import 'package:shuttlemaster/utils/card_formatters.dart';
import 'package:shuttlemaster/utils/card_validators.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMainAppbar(title: 'Top-up Account'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(12),
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.payment, color: Colors.red, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Current Amount',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Rs. 300.00',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Credit/ Debit Card details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              Center(
                child: Container(
                  width: 420,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/icons/visa.png', width: 50),
                  SizedBox(width: 55),
                  Image.asset('assets/icons/mastercard.png', width: 50),
                  SizedBox(width: 55),
                  Image.asset('assets/icons/paypal.png', width: 50),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Card Number',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '1234 5678 9012 3456',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CardNumberFormatter()
                        ],
                        validator: Validators.validateCardNumber,
                      ),
                      SizedBox(height: 15),
                      Text('Expiry Date',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'MM/YY',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ExpiryDateFormatter()
                        ],
                        validator: (value) {
                          return Validators.validateExpiryDate(value);
                        },
                      ),
                      SizedBox(height: 15),
                      Text('Cardholder Name',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Perera A',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z ]'))
                        ],
                        validator: Validators.validateCardHolderName,
                      ),
                      SizedBox(height: 15),
                      Text('CVV (PIN)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '123',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3)
                        ],
                        validator: Validators.validateCVV,
                      ),
                      SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Process the top-up
                    } else {
                      // Show validation errors
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 55, vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Top-up',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';
import 'package:flutter/services.dart';
import 'package:shuttlemaster/utils/card_formatters.dart';
import 'package:shuttlemaster/utils/card_validators.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shuttlemaster/providers/balance_provider.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController amountController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController cardHolderController = TextEditingController();
  TextEditingController cvvController = TextEditingController();

  double enteredAmount = 0.00; // Amount entered by the user

  // Method to call the backend and get the client secret
  Future<void> topUpAccount(BuildContext context, double amount) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body:
            json.encode({'amount': (amount * 100).toInt()}), // Amount in cents
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String clientSecret = data['clientSecret'];

        // Update the balance using Provider
        final balanceProvider =
            Provider.of<BalanceProvider>(context, listen: false);
        balanceProvider.updateBalance(balanceProvider.balance + amount);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Top-up successful! New balance: Rs. ${balanceProvider.balance.toStringAsFixed(2)}'),
        ));

        // Clear fields after successful top-up
        clearFields();
      } else {
        throw Exception('Failed to create payment intent');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to process top-up. Please try again.'),
      ));
    }
  }

  // Method to clear the fields
  void clearFields() {
    amountController.clear();
    cardNumberController.clear();
    expiryDateController.clear();
    cardHolderController.clear();
    cvvController.clear();
    setState(() {
      enteredAmount = 0.00;
    });
  }

  @override
  Widget build(BuildContext context) {
    final balanceProvider = Provider.of<BalanceProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomMainAppbar(
        title: 'Top-up Account',
        showLeading: true,
      ),
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
                  color: theme.colorScheme.surface,
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
                      'Rs. ${balanceProvider.balance.toStringAsFixed(2)}',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Enter Amount to Top-up',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.textTheme.bodyLarge?.color),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Amount (Min: Rs.20)',
                ),
                onChanged: (value) {
                  setState(() {
                    enteredAmount = double.tryParse(value) ?? 0.00;
                  });
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+(\.\d{0,2})?$')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) < 20) {
                    return null;
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              Text(
                'Credit/ Debit Card details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.textTheme.bodyLarge?.color),
              ),
              SizedBox(height: 10),
              Center(
                child: Container(
                  width: 420,
                  height: 1.5,
                  color: theme.dividerColor,
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
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: cardNumberController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Card Number',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CardNumberFormatter()
                        ],
                        validator: Validators.validateCardNumber,
                      ),
                      SizedBox(height: 15),
                      Text('Expiry Date',
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: expiryDateController,
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
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: cardHolderController,
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
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: cvvController,
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
                      if (enteredAmount >= 20) {
                        topUpAccount(context, enteredAmount);
                      } else {
                        // Show Snackbar if amount is less than 20
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Please Enter a Valid Amount (Minimum: Rs. 20)'),
                          ),
                        );
                      }
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

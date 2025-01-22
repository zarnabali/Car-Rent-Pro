import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<bool> makePayment(
      {required int amount, required String currency}) async {
    try {
      String? paymentIntentClientSecret =
          await _createPaymentIntent(amount, currency);
      if (paymentIntentClientSecret == null) return false;

      // Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "drdrake",
        ),
      );

      // Process the payment and wait for the response
      bool isSuccess = await _processPayment();
      return isSuccess; // Return true if the payment is successful
    } catch (e) {
      print('Error in makePayment: $e');
      return false; // Return false if any error occurs
    }
  }

  Future<bool> _processPayment() async {
    try {
      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      // If this line is reached, payment was successful
      return true; // Payment was successful
    } catch (e) {
      print('Error in _processPayment: $e');
      return false; // Payment failed
    }
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": currency,
      };

      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization":
                "Bearer sk_test_51Q6UcNIxAChkB7DUALf4uwsdVauF425Mx4D39I83qxxvj4xWwtFdmSvwaziBH2tyFdCM1J97tvPHaan5ZStWx1jU00hGwxRCyO", // Replace with your actual Stripe secret key
            "Content-Type": "application/x-www-form-urlencoded",
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Payment Intent: ${response.data}');
        return response.data["client_secret"];
      }
      print('Failed to create payment intent: ${response.data}');
      return null;
    } catch (e) {
      print('Error in _createPaymentIntent: $e');
      return null; // Ensure it returns null in case of an error
    }
  }

  String _calculateAmount(int amount) {
    return (amount * 100).toString(); // Convert dollars to cents
  }
}

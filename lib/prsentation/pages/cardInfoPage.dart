import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:rental_app/data/booking.dart';
import 'package:rental_app/prsentation/pages/homepage.dart';
import 'package:rental_app/services/stripe/stripe_service.dart'; // Import for input formatters

class CardInfoPage extends StatefulWidget {
  final Booking booking;

  const CardInfoPage({super.key, required this.booking});
  @override
  _CardInfoPageState createState() => _CardInfoPageState();
}

class _CardInfoPageState extends State<CardInfoPage> {
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();

  bool _isCVCObscured = true;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _expiryDateController.text =
            "${picked.month.toString().padLeft(2, '0')}/${picked.year.toString().substring(2)}";
      });
    }
  }

  Future<void> _processPayment() async {
    try {
      // Call the Stripe service to process the payment
      bool isPaymentSuccessful = await StripeService.instance.makePayment(
        amount: widget.booking.totalPrice.toInt(),
        currency: 'usd',
      );

      if (isPaymentSuccessful) {
        // Payment successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Add the booking to Firestore under the user's collection
        await _addBookingToFirestore(widget.booking);

        // Navigate to Homepage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
        );
      } else {
        // Payment failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Function to add booking to Firestore
  Future<void> _addBookingToFirestore(Booking booking) async {
    try {
      // Reference to Firestore
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Reference to the user's bookings collection
      CollectionReference bookingsRef = firestore
          .collection('Users')
          .doc(booking.userId) // User's document ID
          .collection('Bookings');

      // Add the booking as a new document in the bookings subcollection
      await bookingsRef.add(booking.toMap());

      print("Booking added successfully!");
    } catch (e) {
      print("Error adding booking to Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _expiryDateController.dispose();
    _cardNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int numberOfDays =
        widget.booking.returnDate.difference(widget.booking.pickUpDate).inDays;

    // Calculate price per day dynamically
    double pricePerDay = widget.booking.totalPrice / numberOfDays;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Back button and Header
          Padding(
            padding:
                const EdgeInsets.only(left: 20, bottom: 20, top: 40, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 10),
                Text(
                  'Add your Card details',
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                // Price summary section with total bill and MC image
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey[850]!,
                        Colors.grey[600]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${widget.booking.carName} ${widget.booking.carModel}',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  'assets/images/mc.png', // Keep your image here
                                  height: 44,
                                  width: 44,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text(
                            '\$${widget.booking.totalPrice.toStringAsFixed(1)}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/images/chip.png', // Keep your image here
                              height: 60,
                              width: 60,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${pricePerDay.toStringAsFixed(1)} / day x ${numberOfDays.toString()} days',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Card number field
                TextFormField(
                  controller: _cardNumberController,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Card Number',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/images/mc.png', // Keep your image here
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(
                        19), // Card length 19 including spaces
                    CardNumberInputFormatter(), // Custom formatter for card number format
                  ],
                ),
                SizedBox(height: 20),
                // Expiry Date and CVV row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryDateController,
                        style: GoogleFonts.poppins(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'MM/YY',
                          hintStyle: GoogleFonts.poppins(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: TextFormField(
                        style: GoogleFonts.poppins(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'CVV',
                          hintStyle: GoogleFonts.poppins(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isCVCObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isCVCObscured = !_isCVCObscured;
                              });
                            },
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(
                              3), // Limit to 3 digits
                        ],
                        obscureText: _isCVCObscured,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          // Buttons: Cancel Payment and Pay Now
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // Add cancel logic here
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor:
                          Colors.redAccent, // Button background color
                    ),
                    child: Text(
                      'Cancel Payment',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16), // Space between buttons
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _processPayment();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0), // Make buttons taller
                    ),
                    child: Text(
                      'Pay Now',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Custom Input Formatter for Card Number with spaces
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int selectionIndex = newValue.selection.end;
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formattedText = '';

    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formattedText += ' ';
      }
      formattedText += digitsOnly[i];
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

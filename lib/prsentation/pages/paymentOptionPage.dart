import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_app/data/booking.dart';
import 'package:rental_app/prsentation/pages/cardInfoPage.dart';

class ChoosePaymentOptionsPage extends StatelessWidget {
  final Booking booking;

  const ChoosePaymentOptionsPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Custom Header with Back Button
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, bottom: 20, top: 40, right: 20),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Choose Payment Option',
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Payment Options
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                PaymentOption(
                  image: 'assets/images/mc.png',
                  label: 'Debit / Credit Card',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CardInfoPage(
                                booking: booking,
                              )),
                    );
                  },
                ),
                PaymentOption(
                  image: 'assets/images/qrCode.png',
                  label: 'QRCode',
                  onTap: () {},
                ),
                PaymentOption(
                  image: 'assets/images/gpay.png',
                  label: 'Google Pay',
                  onTap: () {},
                ),
                PaymentOption(
                  image: 'assets/images/pp.png',
                  label: 'Paypal',
                  onTap: () {},
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentOption extends StatelessWidget {
  final String image; // Changed from IconData to image path
  final String label;
  final VoidCallback onTap;

  const PaymentOption({
    required this.image,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  image,
                  height: 30,
                  width: 30,
                ),
                SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

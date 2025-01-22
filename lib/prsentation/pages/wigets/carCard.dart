import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_app/common/images_URL.dart';
import 'package:rental_app/data/Car/car.dart';
import 'package:rental_app/prsentation/pages/car_Details.dart';

class CarCard extends StatelessWidget {
  final Car car;

  const CarCard({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    String imgURl =
        '${AppURLs.firestorage}${Uri.encodeComponent(car.name)}_${Uri.encodeComponent(car.model)}_01.png?${AppURLs.mediaAlt}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                CarDetailsPage(car: car),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // Define the opacity animation
              const begin = 0.0; // Start fully transparent
              const end = 1.0; // End fully opaque
              const curve = Curves.easeInOut; // Animation curve

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var opacityAnimation = animation.drive(tween);

              return FadeTransition(
                opacity: opacityAnimation,
                child: child,
              );
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 5)
          ],
          image: const DecorationImage(
            image: AssetImage('assets/images/blur.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car name and model at the top
            Text(
              car.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            Text(
              car.model,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 10),

            // Car image
            Image.network(
              imgURl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),

            // Price and total price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '${car.pricePerHour.toStringAsFixed(2)} €/HOUR',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Image.asset('assets/images/pump.png'),
                    Text(
                      ' ${car.fuelCapacity.toStringAsFixed(0)} Gallons',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '2,200 KM PER RENTAL',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
            ),
            // Car additional details (seats, doors, transmission)
            const SizedBox(height: 10),
            Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.white, size: 18),
                    const SizedBox(width: 5),
                    Text(
                      '5',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Row(
                  children: [
                    Icon(Icons.lock, color: Colors.white, size: 18),
                    const SizedBox(width: 5),
                    Text(
                      '3',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    children: [
                      Text(
                        'AUTOMATIC',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

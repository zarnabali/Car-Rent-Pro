import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_app/common/images_URL.dart';
import 'package:rental_app/data/Car/car.dart';
import 'package:rental_app/prsentation/pages/bookNow.dart';

class MapsDetailsPage extends StatelessWidget {
  final Car car;

  MapsDetailsPage({super.key, required this.car});

  static const double londonLatitude = 51.5188;
  static const double londonLongitude = -0.1652;

  final mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              minZoom: 15.0,
              maxZoom: 20.0,
              onMapReady: () {
                mapController.move(
                    LatLng(londonLatitude, londonLongitude), 13.0);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: carDetailsCard(car: car, context: context),
          ),
        ],
      ),
    );
  }
}

Widget carDetailsCard({required Car car, required BuildContext context}) {
  return SizedBox(
    height: 350,
    child: Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          width: double.infinity,
          decoration: const BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black38, spreadRadius: 0, blurRadius: 10)
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                '${car.name} ${car.model}',
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.directions_car,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    '> ${car.pricePerHour} \$',
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.battery_full, color: Colors.white, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    car.fuelCapacity.toString(),
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Features",
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                featureIcons(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${car.pricePerHour}€/HOUR',
                      style: GoogleFonts.poppins(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 150,
                      height: 45,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        BookNow(
                                  car: car,
                                ),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  // Define the opacity animation
                                  const begin = 0.0; // Start fully transparent
                                  const end = 1.0; // End fully opaque
                                  const curve =
                                      Curves.easeInOut; // Smooth curve

                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  var opacityAnimation = animation.drive(tween);

                                  // Increase duration for smoother transition
                                  return FadeTransition(
                                    opacity: opacityAnimation,
                                    child: child,
                                  );
                                },
                                transitionDuration: Duration(
                                    milliseconds: 500), // Adjust this duration
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black),
                          child: Text(
                            'Book Now',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 10,
          child: SizedBox(
            width: 270,
            height: 170,
            child: Image.network(
              '${AppURLs.firestorage}${Uri.encodeComponent(car.name)}_${Uri.encodeComponent(car.model)}_02.png?${AppURLs.mediaAlt}',
              fit: BoxFit.fill,
            ),
          ),
        )
      ],
    ),
  );
}

// Other functions remain the same...

Widget featureIcons() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      featureIcon(Icons.local_gas_station, 'Diesel', 'Common Rail'),
      featureIcon(Icons.speed, 'Acceleration', '0 - 100km/s'),
      featureIcon(Icons.ac_unit, 'Cold', 'Temp Control'),
    ],
  );
}

Widget featureIcon(IconData icon, String title, String subtitle) {
  return Container(
    width: 120,
    height: 100,
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 1)),
    child: Column(
      children: [
        Icon(
          icon,
          size: 28,
        ),
        Text(title, style: GoogleFonts.poppins()),
        Text(
          subtitle,
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10),
        )
      ],
    ),
  );
}

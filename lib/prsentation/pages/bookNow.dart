import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rental_app/common/images_URL.dart';
import 'package:rental_app/data/Car/car.dart';
import 'package:rental_app/data/booking.dart';
import 'package:rental_app/prsentation/pages/paymentOptionPage.dart';

class BookNow extends StatefulWidget {
  final Car car;

  BookNow({super.key, required this.car});

  @override
  State<BookNow> createState() => _BookNowState();
}

Future<String?> fetchUserUid() async {
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    // Return the UID of the current user
    return currentUser.uid;
  } else {
    // Return null if no user is signed in
    return null;
  }
}

class _BookNowState extends State<BookNow> {
  static const double londonLatitude = 51.5188;
  static const double londonLongitude = -0.1652;

  final MapController mapController = MapController();

  // Pickup and return date controllers
  DateTime? pickupDate;
  DateTime? returnDate;

  // Total price variable
  double totalPrice = 0;

  // Pickup location dropdown value
  String selectedLocation =
      "London Car Rentals, 300 Harrow Rd, Wembley HA9 6LL";

  // Function to select a date
  Future<void> _selectDate(BuildContext context, bool isPickup) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != (isPickup ? pickupDate : returnDate)) {
      setState(() {
        if (isPickup) {
          pickupDate = picked;
          totalPrice = calculateTotalAmount();
        } else {
          returnDate = picked;
          totalPrice = calculateTotalAmount();
        }
        // Update total price whenever the dates change
        totalPrice = calculateTotalAmount();
      });
    }
  }

  // Calculate total amount based on the number of days
  double calculateTotalAmount() {
    if (pickupDate != null && returnDate != null) {
      int noOfDays = returnDate!.difference(pickupDate!).inDays;
      if (noOfDays < 1) noOfDays = 1; // Minimum booking is 1 day
      return widget.car.pricePerHour * 24 * noOfDays;
    }
    return 0;
  }

  Future<String?> fetchUserUid() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Return the UID of the current user
      return currentUser.uid;
    } else {
      // Return null if no user is signed in
      return null;
    }
  }

  void bookDetails() async {
    if (pickupDate == null || returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select both pickup and return dates')),
      );
      return;
    }
    if (pickupDate!.isAfter(returnDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pickup date cannot be after return date')),
      );
      return;
    }

    String? userId = await fetchUserUid(); // Await the UID fetching

    // Check if userId is null
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not signed in')),
      );
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(
                'Booking confirmed. Total: \$${totalPrice.toStringAsFixed(2)}'),
            duration: const Duration(
                seconds: 2), // Optional: Set duration for the SnackBar
          ),
        )
        .closed
        .then((value) {
      Booking booking = Booking(
        userId: userId,
        carName: widget.car.name,
        carModel: widget.car.model,
        totalPrice: totalPrice,
        pickUpDate: pickupDate!,
        returnDate: returnDate!,
      );

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ChoosePaymentOptionsPage(
            booking: booking,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Define the opacity animation
            const begin = 0.0; // Start fully transparent
            const end = 1.0; // End fully opaque
            const curve = Curves.easeInOut; // Smooth curve

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var opacityAnimation = animation.drive(tween);

            // Increase duration for smoother transition
            return FadeTransition(
              opacity: opacityAnimation,
              child: child,
            );
          },
          transitionDuration:
              const Duration(milliseconds: 500), // Adjust this duration
        ),
      );
    });
  }

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
            child: carDetailsCard(
                car: widget.car,
                pickupDate: pickupDate,
                returnDate: returnDate,
                selectDate: _selectDate,
                onBookNow: bookDetails,
                selectedLocation: selectedLocation,
                onLocationChanged: (String? newLocation) {
                  setState(() {
                    if (newLocation != null) {
                      selectedLocation = newLocation;
                    }
                  });
                },
                totalPrice: totalPrice, // Pass totalPrice to card
                context: context),
          ),
        ],
      ),
    );
  }
}

Widget carDetailsCard(
    {required Car car,
    DateTime? pickupDate,
    DateTime? returnDate,
    required Function(BuildContext, bool) selectDate,
    required Function() onBookNow,
    required String selectedLocation,
    required Function(String?) onLocationChanged,
    required double totalPrice, // Accept totalPrice as a parameter
    context}) {
  double screenHeight = MediaQuery.of(context).size.height;
  double minCardHeight = 470.0; // Minimum height to prevent underflow
  double cardHeight = screenHeight * 0.5; // Responsive height
  return SizedBox(
    height: cardHeight < minCardHeight ? minCardHeight : cardHeight,
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
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                '${car.name} ${car.model}',
                style: GoogleFonts.poppins(
                    fontSize: screenHeight * 0.03, // Responsive text size
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.directions_car,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 5),
                  Text('${car.pricePerHour} €/hour',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: screenHeight * 0.018 // Responsive text size
                          )),
                  const SizedBox(width: 10),
                  const Icon(Icons.battery_full, color: Colors.white, size: 14),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          top: 125,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter Booking Details",
                  style: GoogleFonts.poppins(
                      fontSize: screenHeight * 0.03,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                bookingDetails(pickupDate, returnDate, selectDate,
                    selectedLocation, onLocationChanged, context),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${totalPrice.toStringAsFixed(1)} €/total',
                      style: GoogleFonts.poppins(
                          fontSize: screenHeight * 0.035,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: screenHeight * 0.15,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: onBookNow,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black),
                        child: Text(
                          'Payment',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenHeight * 0.02),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 10,
          child: SizedBox(
            width: 270, // Set desired width
            height: 170, // Set desired height
            child: Image.network(
              '${AppURLs.firestorage}${Uri.encodeComponent(car.name)}_${Uri.encodeComponent(car.model)}_02.png?${AppURLs.mediaAlt}',
              fit: BoxFit.fill, // Adjusts the image within the box
            ),
          ),
        ),
      ],
    ),
  );
}

Widget bookingDetails(
  DateTime? pickupDate,
  DateTime? returnDate,
  Function(BuildContext, bool) selectDate,
  String selectedLocation,
  Function(String?) onLocationChanged,
  BuildContext context,
) {
  double screenWidth = MediaQuery.of(context).size.width;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DropdownButtonFormField<String>(
        value: selectedLocation.isEmpty ? null : selectedLocation,
        items: const [
          DropdownMenuItem(
            value: "London Car Rentals, 300 Harrow Rd, Wembley HA9 6LL",
            child: Text(
              "London Car Rentals, 300 Harrow Rd, Wembley HA9 6LL",
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          // Add more locations here if needed
        ],
        onChanged: onLocationChanged,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Pickup Location',
          hintText: 'Pick a location',
          labelStyle: GoogleFonts.poppins(
            fontSize: screenWidth * 0.04, // Larger title size
          ),
          hintStyle: GoogleFonts.poppins(
            fontSize: screenWidth * 0.04, // Hint text size
          ),
          border: const OutlineInputBorder(),
        ),
        style: GoogleFonts.poppins(
          fontSize: screenWidth * 0.04, // Larger dropdown text
        ),
        dropdownColor: Colors.white,
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => selectDate(context, true),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  pickupDate == null
                      ? 'Select Pickup Date'
                      : DateFormat('dd/MM/yyyy').format(pickupDate!),
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.04, // Responsive text size
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => selectDate(context, false),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  returnDate == null
                      ? 'Select Return Date'
                      : DateFormat('dd/MM/yyyy').format(returnDate!),
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.04, // Responsive text size
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

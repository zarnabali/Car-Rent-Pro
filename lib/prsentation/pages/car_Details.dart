import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_app/data/Car/car.dart';
import 'package:rental_app/prsentation/pages/MapDetailsPage.dart';
import 'package:rental_app/prsentation/pages/bookNow.dart';
import 'package:rental_app/prsentation/pages/wigets/carCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarDetailsPage extends StatefulWidget {
  final Car car;

  const CarDetailsPage({super.key, required this.car});

  @override
  State<CarDetailsPage> createState() => _CarDetailsPageState();
}

class _CarDetailsPageState extends State<CarDetailsPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  String userEmail = ''; // Store the current user's trimmed email

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 3), vsync: this);

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(_controller!)
      ..addListener(() {
        setState(() {});
      });

    _controller!.forward();
    fetchUserEmail(); // Fetch the user's email when the widget is initialized
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  // Function to fetch the current user's email from Firestore
  Future<void> fetchUserEmail() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Fetch user data from Firestore using the UID of the current user
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      String email = userDoc['email'] ?? 'Unknown User';
      // Trim the email to remove the part after '@'
      setState(() {
        userEmail = email.split('@')[0]; // Extract the part before '@'
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 18, 18, 18),
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the back button color to white
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            Text(
              ' Information',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w400),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          CarCard(
            car: Car(
                name: widget.car.name,
                model: widget.car.model,
                fuelCapacity: widget.car.fuelCapacity,
                pricePerHour: widget.car.pricePerHour,
                status: widget.car.status),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: const Color(0xffF3F3F3),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              spreadRadius: 5)
                        ]),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage('assets/images/user.png'),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          userEmail, // Display the trimmed email (part before @)
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  MapsDetailsPage(car: widget.car),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            // Define the opacity animation
                            const begin = 0.0; // Start fully transparent
                            const end = 1.0; // End fully opaque
                            const curve = Curves.easeInOut; // Animation curve

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
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
                      height: 170,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                spreadRadius: 5)
                          ]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Transform.scale(
                          scale: _animation!.value,
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/maps.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Container(),
          )
        ],
      ),
    );
  }
}

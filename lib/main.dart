import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:rental_app/firebase_options.dart';
import 'package:rental_app/prsentation/pages/homepage.dart';
import 'package:rental_app/prsentation/widgets/pages/get_started.dart';
import 'package:rental_app/services/stripe/keys.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    Stripe.publishableKey = STRIPE_PUBLISHABLE_KEY;
  } catch (e) {
    print("Error initializing Firebase and Stripe: $e");
    return; // Stop execution if initialization fails
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Car Rental",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: OnboardingPage(),
    );
  }
}




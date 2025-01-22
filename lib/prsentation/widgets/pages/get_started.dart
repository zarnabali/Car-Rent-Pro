import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_app/prsentation/pages/authentication/bloc/authGate.dart';
import 'package:rental_app/prsentation/pages/homepage.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 33, 38),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/onboarding.png'),
                      fit: BoxFit.cover)),
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Premium cars. \nEnjoy the luxury',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Premium and prestige car daily rental. \nExperience the thrill at a lower price',
                    style:
                        GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 320,
                    height: 54,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AuthGate(), //const Homepage() ,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white),
                        child: Text(
                          'Let\'s Go',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w900),
                        )),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

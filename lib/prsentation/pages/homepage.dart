import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:rental_app/data/Car/car.dart';
import 'package:rental_app/data/booking.dart';
import 'package:rental_app/prsentation/pages/wigets/carCard.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  File? _imageFile; // For storing the selected profile image
  final _picker = ImagePicker(); // Image picker instance

  // Fetch cars data from Firestore
  Future<List<Car>> fetchCars() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Cars').get();

    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return Car(
        name: data['Name'] ?? 'Unknown',
        model: data['Model'] ?? 'Unknown',
        fuelCapacity: (data['Fuel_Capacity'] ?? 0.0).toDouble(),
        pricePerHour: (data['Price_Per_Hour'] ?? 18.0).toDouble(),
        status: data['Status'] ?? false,
      );
    }).toList();
  }

  // Placeholder widgets for the other pages
  Widget _buildHomePage() {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Padding(
          padding:
              const EdgeInsets.only(left: 25, top: 10, bottom: 10, right: 35),
          child: Text(
            'Choose Your Car',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: FutureBuilder<List<Car>>(
        future: fetchCars(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: GoogleFonts.poppins(color: Colors.white)),
            );
          } else if (snapshot.hasData) {
            final cars = snapshot.data!;
            return ListView.builder(
              itemCount: cars.length,
              itemBuilder: (context, index) {
                return CarCard(car: cars[index]);
              },
            );
          }
          return Center(
            child: Text('No cars available',
                style: GoogleFonts.poppins(color: Colors.white)),
          );
        },
      ),
    );
  }

  Future<List<Booking>> fetchUserBookings() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return []; // No user is logged in
    }

    // Query the user's bookings
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Bookings')
        .get();

    // Convert each booking document into a Booking object
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return Booking.fromMap(data);
    }).toList();
  }

  // Bookings Page with added styling and swipe-to-delete functionality
  Widget _buildBookingsPage() {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Padding(
          padding:
              const EdgeInsets.only(left: 25, top: 10, bottom: 10, right: 35),
          child: Text(
            'Manage Your Bookings',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: FutureBuilder<List<Booking>>(
        future: fetchUserBookings(), // Fetch bookings from Firebase
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: GoogleFonts.poppins(color: Colors.white)),
            );
          } else if (snapshot.hasData) {
            final bookings = snapshot.data!;
            if (bookings.isEmpty) {
              return Center(
                child: Text('No bookings available',
                    style: GoogleFonts.poppins(color: Colors.white)),
              );
            }

            return ListView.separated(
              itemCount: bookings.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey[700], // Line color
                thickness: 1, // Line thickness
              ),
              itemBuilder: (context, index) {
                final booking = bookings[index];

                return Dismissible(
                  key: Key(booking.userId), // Unique key for each booking
                  direction:
                      DismissDirection.endToStart, // Swipe left to delete
                  background: Container(
                    color: Colors.redAccent, // Background color when swiped
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    // Remove booking from Firebase
                    _deleteBooking(booking);
                    // Show a message after deletion
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${booking.carName} deleted',
                            style: GoogleFonts.poppins(color: Colors.white)),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(
                      booking.carName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      'Model: ${booking.carModel}\nPick-up: ${booking.pickUpDate.toLocal()}'
                      '\nReturn: ${booking.returnDate.toLocal()}',
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Text(
                      'Total: \$${booking.totalPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(255, 114, 225, 29),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Center(
            child: Text('No bookings available',
                style: GoogleFonts.poppins(color: Colors.white)),
          );
        },
      ),
    );
  }

// Function to delete booking from Firebase
  Future<void> _deleteBooking(Booking booking) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('Bookings')
          .where('userId', isEqualTo: user.uid)
          .where('carName', isEqualTo: booking.carName)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
    }
  }

  // Profile Page with Image, Name, Email, and Logout Button
  // Profile Page with Image, Name, Email, and Logout Button
  Widget _buildProfilePage() {
    final User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? 'No Email';
    String userName = userEmail.split('@')[0]; // Extract username from email

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Padding(
          padding:
              const EdgeInsets.only(left: 25, top: 10, bottom: 10, right: 35),
          child: Text(
            'Hi $userName',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        // Allows vertical scroll if the content overflows
        child: Center(
          // Centers both horizontally and vertically
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 150),
              GestureDetector(
                onTap: () => _pickImageFromGallery(), // Pick image from gallery
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(Icons.camera_alt,
                          size: 40, color: Colors.white)
                      : null,
                  backgroundColor:
                      Colors.grey[800], // Background color for avatar
                ),
              ),
              const SizedBox(height: 20),
              Text(
                userName,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 26, // Larger text for better emphasis
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                userEmail,
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _logoutUser,
                child: Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Rounded button shape
                  ),
                  elevation: 5, // Button shadow for better styling
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pick an image from the gallery
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Logout user from Firebase
  Future<void> _logoutUser() async {
    await FirebaseAuth.instance.signOut();
    // Redirect to login page after logout
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      _buildHomePage(),
      _buildBookingsPage(),
      _buildProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF121212),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon:
                _buildIconWithText(Icons.home, Icons.home_outlined, "Home", 0),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildIconWithText(
                Icons.book_online, Icons.book_online_outlined, "Bookings", 1),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildIconWithText(
                Icons.person, Icons.person_outline, "Profile", 2),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle:
            GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle:
            GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        onTap: _onItemTapped,
        elevation: 10,
      ),
    );
  }

  Widget _buildIconWithText(
      IconData filledIcon, IconData outlinedIcon, String text, int index) {
    bool isSelected = _selectedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(vertical: isSelected ? 8 : 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? filledIcon : outlinedIcon,
            color: isSelected ? Colors.white : Colors.grey,
            size: isSelected ? 28 : 24,
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: isSelected ? 14 : 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental_app/data/Car/car.dart';

class CarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to fetch cars from Firestore based on the latest added
  Future<List<Car>> getCars() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Cars')
          .orderBy('created_at', descending: true)
          .get();

      List<Car> carList = snapshot.docs.map((doc) {
        return Car.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return carList;
    } catch (e) {
      print("Error fetching car data: $e");
      return [];
    }
  }
}

import 'package:rental_app/data/Car/car.dart';
import 'package:rental_app/data/Car/carService.dart';

class CarRepository {
  final CarService _carService = CarService();

  // Method to get the list of cars from the service
  Future<List<Car>> fetchCarList() async {
    return await _carService.getCars();
  }
}

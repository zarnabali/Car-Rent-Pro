import 'package:rental_app/data/Car/car.dart';
import 'package:rental_app/data/Car/carRepositary.dart';

class GetCarsUseCase {
  final CarRepository _carRepository;

  GetCarsUseCase(this._carRepository);

  // Method to execute the use case of fetching cars
  Future<List<Car>> execute() async {
    return await _carRepository.fetchCarList();
  }
}

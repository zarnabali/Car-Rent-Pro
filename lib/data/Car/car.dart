class Car {
  final String name;
  final String model;
  final double fuelCapacity; // Correct spelling
  final double pricePerHour;
  final bool status;

  Car({
    required this.name,
    required this.model,
    required this.fuelCapacity, // Corrected
    required this.pricePerHour,
    required this.status,
  });

  // A factory method to create a Car instance from a Firestore document
  factory Car.fromMap(Map<String, dynamic> data) {
    return Car(
      name: data['Name'] ?? 'Unknown',
      model: data['Model'] ?? 'Unknown',
      fuelCapacity:
          (data['Fuel_Capacity'] ?? 0.0).toDouble(), // Correct spelling
      pricePerHour: (data['Price_Per_Hour'] ?? 0.0).toDouble(),
      status: data['Status'] ?? false,
    );
  }
}

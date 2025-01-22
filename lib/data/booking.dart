class Booking {
  final String userId;
  final String carName;
  final String carModel;
  final double totalPrice;
  final DateTime pickUpDate;
  final DateTime returnDate;

  Booking({
    required this.userId,
    required this.carName,
    required this.carModel,
    required this.totalPrice,
    required this.pickUpDate,
    required this.returnDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'carName': carName,
      'carModel': carModel,
      'totalPrice': totalPrice,
      'pickUpDate': pickUpDate.toIso8601String(),
      'returnDate': returnDate.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> data) {
    return Booking(
      userId: data['userId'] ?? '',
      carName: data['carName'] ?? '',
      carModel: data['carModel'] ?? '',
      totalPrice: data['totalPrice'] ?? '',
      pickUpDate: DateTime.parse(data['pickUpDate']),
      returnDate: DateTime.parse(data['returnDate']),
    );
  }
}

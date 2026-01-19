class PaymentMethod {
  String fullName;
  String email;
  String cardNumber;
  String expiryDate;
  String cvv;
  String country;
  String zip;
  //String method; // 'card', 'apple_pay', 'google_pay'

  PaymentMethod({
    required this.fullName,
    required this.email,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.country,
    required this.zip,
    //required this.method,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'country': country,
      'zip': zip,
      //'method': method,
    };
  }
}

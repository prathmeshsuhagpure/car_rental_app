import 'dart:convert';
import 'package:car_rent_app/models/payment_method_model.dart';
import 'package:car_rent_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';

class PaymentService {
  static String? baseUrl = ApiConstants.baseUrl;

  Future<void> submitPaymentForm(
    BuildContext context,
    PaymentMethod data,
  ) async {
    try {
      final headers = await ApiService().getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.createPayment}'),
        headers: headers,
        body: jsonEncode(data.toJson()),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201 && result['success'] == true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Saved!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

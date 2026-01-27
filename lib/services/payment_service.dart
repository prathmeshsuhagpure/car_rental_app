import 'dart:convert';
import 'package:car_rent_app/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'api_endpoints.dart';

class PaymentService {
  static String? baseUrl = ApiConstants.baseUrl;

  // Submit card payment form
/*  Future<Map<String, dynamic>> submitPaymentForm(
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (result['success'] == true) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment information saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          return {
            'success': true,
            'message': 'Payment saved successfully',
            'data': result['data'],
          };
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Payment failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return {
            'success': false,
            'message': result['message'] ?? 'Payment failed',
          };
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: ${result['message'] ?? 'Unknown error'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return {
          'success': false,
          'message': result['message'] ?? 'Payment failed',
        };
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }*/

  // Create Razorpay Order
  Future<Map<String, dynamic>> createRazorpayOrder({
    required double amount,
    required String currency,
  }) async {
    try {
      final headers = await ApiService().getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.createRazorpayOrder}'),
        headers: headers,
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
        }),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (result['success'] == true && result['orderId'] != null) {
          return {
            'success': true,
            'orderId': result['orderId'],
            'amount': result['amount'],
            'currency': result['currency'],
          };
        } else {
          return {
            'success': false,
            'message': result['message'] ?? 'Failed to create order',
          };
        }
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to create order',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Verify Razorpay Payment
  /*Future<Map<String, dynamic>> verifyPayment(
      Map<String, dynamic> paymentData,
      ) async {
    try {
      final headers = await ApiService().getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.verifyRazorpayPayment}'),
        headers: headers,
        body: jsonEncode(paymentData),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': result['success'] ?? false,
          'message': result['message'] ?? 'Payment verification completed',
          'paymentId': result['paymentId'],
        };
      } else {
        print(result['message']);
        return {
          'success': false,
          'message': result['message'] ?? 'Payment verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }*/

  Future<Map<String, dynamic>> verifyPayment(
      PaymentSuccessResponse response,
      ) async {
    try {
      final headers = await ApiService().getHeaders();

      final body = {
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
        'razorpay_signature': response.signature,
      };

      final res = await http.post(
        Uri.parse('$baseUrl${ApiConstants.verifyRazorpayPayment}'),
        headers: {
          ...headers,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final result = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return {
          'success': true,
          'message': result['message'],
          'paymentId': result['paymentId'],
        };
      }

      return {
        'success': false,
        'message': result['message'] ?? 'Verification failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }


  // Get Payment History
  Future<Map<String, dynamic>> getPaymentHistory() async {
    try {
      final headers = await ApiService().getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.getPaymentHistory}'),
        headers: headers,
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'payments': result['payments'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to fetch payment history',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Get Payment Details by ID
  Future<Map<String, dynamic>> getPaymentById(String paymentId) async {
    try {
      final headers = await ApiService().getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.getPaymentById}/$paymentId'),
        headers: headers,
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'payment': result['payment'],
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to fetch payment details',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Refund Payment (if needed)
  Future<Map<String, dynamic>> refundPayment({
    required String paymentId,
    required double amount,
    String? reason,
  }) async {
    try {
      final headers = await ApiService().getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.refundPayment}'),
        headers: headers,
        body: jsonEncode({
          'paymentId': paymentId,
          'amount': amount,
          'reason': reason ?? 'Booking cancellation',
        }),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': result['success'] ?? false,
          'message': result['message'] ?? 'Refund processed',
          'refundId': result['refundId'],
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Refund failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
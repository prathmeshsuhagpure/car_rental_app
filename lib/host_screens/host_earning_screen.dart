import 'package:flutter/material.dart';
import '../models/earning_moedl.dart';
import '../services/api_service.dart';

class HostEarningsScreen extends StatelessWidget {
  const HostEarningsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    return Scaffold(
      appBar: AppBar(title: const Text('My Earnings')),
      body: FutureBuilder<HostEarnings>(
        future: apiService.fetchHostEarnings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final earnings = snapshot.data!;

          return Column(
            children: [

              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          "Total Earnings",
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "₹${earnings.totalEarnings}",
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // PER CAR EARNINGS
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: earnings.cars.length,
                  itemBuilder: (context, index) {
                    final car = earnings.cars[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: car.image != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            car.image!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        )
                            : const Icon(Icons.directions_car),
                        title: Text("${car.brand} ${car.model}"),
                        trailing: Text(
                          "₹${car.earnings}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

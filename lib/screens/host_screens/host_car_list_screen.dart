import 'package:flutter/material.dart';
import '../../models/car_model.dart';
import '../../services/api_service.dart';
import 'helper/host_car_card.dart';

class HostCarListScreen extends StatefulWidget {
  const HostCarListScreen({super.key});

  @override
  State<HostCarListScreen> createState() => HostCarsScreenState();
}

class HostCarsScreenState extends State<HostCarListScreen> {
  late Future<List<Car>> _carsFuture;
  final apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _carsFuture = apiService.fetchHostCars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Hosted Cars'),
      ),
      body: FutureBuilder<List<Car>>(
        future: _carsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final cars = snapshot.data!;

          if (cars.isEmpty) {
            return const Center(
              child: Text('No cars hosted yet'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return HostCarCard(car: car);
            },
          );
        },
      ),
    );
  }
}

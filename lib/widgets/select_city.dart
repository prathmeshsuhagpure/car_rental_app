import 'package:flutter/material.dart';

Future<String?> showCitySelectionSheet(BuildContext context) async {
  final List<String> allCities = [
    'Nagpur',
    'Pune',
    'Delhi NCR',
    'Mumbai',
    'Chennai',
    'Hyderabad',
    'Chandigarh',
    'Kolkata',
    'Ahmedabad',
    'Coimbatore',
    'Indore',
  ];

  String searchQuery = '';

  return await showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final filteredCities = allCities
              .where(
                (city) =>
                city.toLowerCase().contains(searchQuery.toLowerCase()),
          )
              .toList();

          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Select City',
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setModalState(() => searchQuery = value);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 400,
                  child: ListView.builder(
                    itemCount: filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = filteredCities[index];
                      //final isEnabled = city == 'Nagpur';
                      final isEnabled = true;

                      return ListTile(
                        title: Text(city),
                        enabled: isEnabled,
                        tileColor:
                        isEnabled ? null : Colors.grey.shade300,
                        onTap: () => Navigator.pop(context, city)
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

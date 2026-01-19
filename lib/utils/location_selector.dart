import 'package:flutter/material.dart';

Future<String?> showLocationSuggestions(
    BuildContext context, List<String> locationSuggestions) async {
  String searchQuery = '';

  return await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final filteredCities = locationSuggestions
              .where((city) =>
              city.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Location',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF475569)),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        prefixIcon:
                        Icon(Icons.search, color: Colors.grey[400]),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (value) {
                        setModalState(() => searchQuery = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 400,
                    child: filteredCities.isEmpty
                        ? const Center(
                      child: Text(
                        'No cities found.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                        : ListView.separated(
                      itemCount: filteredCities.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.grey[700],
                      ),
                      itemBuilder: (context, index) {
                        final city = filteredCities[index];
                        const isEnabled = true;

                        return ListTile(
                          title: Text(
                            city,
                            style: const TextStyle(color: Colors.white),
                          ),
                          enabled: isEnabled,
                          onTap: () {
                            if (isEnabled) {
                              Navigator.pop(context, city);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
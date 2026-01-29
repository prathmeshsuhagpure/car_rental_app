import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/car_model.dart';
import '../providers/favourites_provider.dart';
import '../screens/user_screens/car/car_detail_screen.dart';

class CarCard extends StatefulWidget {
  final Car car;
  final int? index;
  final DateTime startDate;
  final DateTime endDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const CarCard({
    super.key,
    required this.car,
    this.index,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<CarCard> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final car = widget.car;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailScreen(
              car: car,
              startDate: widget.startDate,
              endDate: widget.endDate,
              startTime: widget.startTime,
              endTime: widget.endTime,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- IMAGE SECTION ----------------
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: car.images.isNotEmpty
                        ? CarouselSlider(
                      options: CarouselOptions(
                        height: 200,
                        viewportFraction: 1.0,
                        enableInfiniteScroll:
                        car.images.length > 1,
                        autoPlay: car.images.length > 1,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                      ),
                      items: car.images.map((imageUrl) {
                        return Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder:
                              (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.directions_car,
                                size: 80,
                                color: Colors.white,
                              ),
                            );
                          },
                        );
                      }).toList(),
                    )
                        : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.directions_car,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Rating Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Text(
                          car.rating.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star,
                            color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '| ${car.reviews}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

                // Favourite Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: Consumer<FavoritesProvider>(
                    builder: (context, favProvider, _) {
                      final isFav = favProvider.isFavorite(car.id);
                      return InkWell(
                        onTap: () => favProvider.toggleFavorite(car.id),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 18,
                          child: Icon(
                            isFav
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.black54,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // ---------------- DETAILS SECTION ----------------
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    car.title,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 6),

                  // Fuel | Seats | Transmission
                  Row(
                    children: [
                      _infoChip(Icons.local_gas_station,
                          car.fuelType),
                      _infoChip(Icons.event_seat,
                          '${car.seats} Seats'),
                      _infoChip(Icons.settings,
                          car.transmission),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Distance + FASTag
                  Row(
                    children: [
                      const Icon(
                        Icons.place,
                        size: 16,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),

                      /// 📍 State + pincode + distance
                      Expanded(
                        child: Text(
                          car.formattedDistance.isNotEmpty
                              ? '${car.location.stateWithPincode} • ${car.formattedDistance} away'
                              : car.location.stateWithPincode,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      if (car.hasActiveFastTag) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'FASTag',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Prices
                  Row(
                    children: [
                      Text(
                        '₹${car.originalPrice}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                          decoration:
                          TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${car.offerPrice} / day',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
                fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

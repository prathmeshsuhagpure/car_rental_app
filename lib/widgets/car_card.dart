import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/car_model.dart';
import '../screens/car/car_detail_screen.dart';

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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
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
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    color: Colors.grey[300],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: car.images.isNotEmpty
                          ? Stack(
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 200,
                              viewportFraction: 1.0,
                              enableInfiniteScroll: car.images.length > 1,
                              autoPlay: car.images.length > 1,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                            ),
                            items: car.images.map((imageUrl) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: Icon(
                                          Icons.directions_car,
                                          size: 80,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          // Dot Indicators
                          if (car.images.length > 1)
                            Positioned(
                              bottom: 8,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: car.images.asMap().entries.map((entry) {
                                  return Container(
                                    width: 8.0,
                                    height: 8.0,
                                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentImageIndex == entry.key
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.4),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      )
                          : Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(
                            Icons.directions_car,
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          car.rating.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.star, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          '| ${car.reviews}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      car.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: car.isFavorite ? Colors.red : Colors.black54,
                      size: 20,
                    ),
                  ),
                ),
                // Guest Favorite badge
                if (car.isGuestFavorite)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[700],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Guest Favourite',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    car.subTitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.directions_walk, size: 16, color: Colors.black54),
                      SizedBox(width: 4),
                      Text(
                        car.distance,
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      Spacer(),
                      Text(
                        "₹${car.pricePerDay} /hr",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      if (car.hasActiveFastTag)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Active FASTag',
                            style: TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                        ),
                      Spacer(),
                      Text(
                        "₹${car.totalPrice} excluding fees",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          decoration: TextDecoration.underline,
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
}

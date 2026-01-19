import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/date_time_selection.dart';
import '../../utils/helper.dart';
import '../../utils/location_selector.dart';
import '../../widgets/booking_header.dart';
import '../../widgets/trip_date_select.dart';
import '../car/car_list_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({
    super.key,
  });

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with TickerProviderStateMixin {
  final TextEditingController _locationController = TextEditingController();
  bool _deliveryPickup = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late DateTimeSelectionService _dateTimeService;

  @override
  void initState() {
    super.initState();
    _dateTimeService = DateTimeSelectionService();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleLocationTap() async {
    final selected =
    await showLocationSuggestions(context, locationSuggestions);
    if (selected != null) {
      setState(() {
        _locationController.text = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ListenableBuilder(
            listenable: _dateTimeService,
            builder: (context, child) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const BookingHeader(),
                    // Search Box
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF334155).withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _handleLocationTap,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFF475569)),
                                borderRadius: BorderRadius.circular(16),
                                color: const Color(0xFF334155),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search,
                                      color: Color(0xFF059669)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _locationController.text.isEmpty
                                          ? "Search for the location"
                                          : _locationController.text,
                                      style: TextStyle(
                                        color: _locationController.text.isEmpty
                                            ? Colors.grey[400]
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.gps_fixed,
                                      color: Color(0xFF059669)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Date Selection
                    Row(
                      children: [
                        Expanded(
                          child: TripDateSelect(
                            title: 'Trip Start',
                            date: _dateTimeService.tripStartDate,
                            time: _dateTimeService.tripStartTime,
                            onTap: () => _dateTimeService.selectStartDateTime(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TripDateSelect(
                            title: 'Trip End',
                            date: _dateTimeService.tripEndDate,
                            time: _dateTimeService.tripEndTime,
                            onTap: () => _dateTimeService.selectEndDateTime(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Delivery Pickup Checkbox
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF059669).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _deliveryPickup,
                            onChanged: (value) {
                              setState(() {
                                _deliveryPickup = value!;
                              });
                              HapticFeedback.selectionClick();
                            },
                            activeColor: const Color(0xFF059669),
                            checkColor: Colors.white,
                            fillColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return const Color(0xFF059669);
                              }
                              return Colors.white;
                            }),
                          ),
                          const Expanded(
                            child: Text(
                              "Delivery & Pick-up, from anywhere",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Icon(Icons.local_shipping,
                              color: const Color(0xFF059669)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Search Button
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF059669), Color(0xFF10B981)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF059669).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          if (_locationController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select a Location."),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          // Validate dates using the service
                          if (!_dateTimeService.isValidDateRange) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Trip end must be after trip start."),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Searching for cars..."),
                              backgroundColor: Color(0xFF059669),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(milliseconds: 500),
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CarListScreen(
                                selectedLocation: _locationController.text,
                                startDate: _dateTimeService.tripStartDate,
                                startTime: _dateTimeService.tripStartTime,
                                endDate: _dateTimeService.tripEndDate,
                                endTime: _dateTimeService.tripEndTime,
                                deliveryPickup: _deliveryPickup,
                              ),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "SEARCH CARS",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Car Selection Section
                    /*Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.star,
                                  color: Color(0xFF059669),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Unmatched Selection",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Our Finest Cars for Your Next Adventure",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF059669).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF059669).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              "For your trip on ${_dateTimeService.tripStartDate.day} ${TimeUtils.getMonthName(_dateTimeService.tripStartDate.month)} - ${_dateTimeService.tripEndDate.day} ${TimeUtils.getMonthName(_dateTimeService.tripEndDate.month)}",
                              style: const TextStyle(
                                color: Color(0xFF059669),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          *//*GridView.builder(
                            itemCount: CarData.cars.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 280,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemBuilder: (context, index) {
                              final carMap = CarData.cars[index];
                              final car = Car.fromMap(carMap);
                              return EnhancedCarCard(
                                car: car,
                                index: index,
                                startDate: _dateTimeService.tripStartDate,
                                endDate: _dateTimeService.tripEndDate,
                              );
                            },
                          ),
                          const SizedBox(height: 20),*//*
                        ],
                      ),
                    ),*/
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
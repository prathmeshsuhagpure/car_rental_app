import 'package:car_rent_app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../../../providers/date_time_selection_provider.dart';
import '../../../utils/helper.dart';
import '../../../utils/location_selector.dart';
import '../../../utils/theme.dart';
import '../../../widgets/trip_date_select.dart';
import '../car/car_list_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  BookingScreenState createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen>
    with TickerProviderStateMixin {
  final TextEditingController _locationController = TextEditingController();
  bool _deliveryPickup = false;
  Position? _currentPosition;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late DateTimeSelectionProvider _dateTimeService;

  @override
  void initState() {
    super.initState();
    _dateTimeService = DateTimeSelectionProvider();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    _getCurrentLocation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        _showError(context, 'Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          _showError(context, 'Location permissions denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        _showError(context, 'Location permissions permanently denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      if (!mounted) return;
      _showError(context, 'Failed to get location: $e');
    }
  }

  Future<void> _handleLocationTap() async {
    final selected =
        await showLocationSuggestions(context, locationSuggestions);
    if (selected != null) {
      setState(() => _locationController.text = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: "Daily Drive",
        iconButton: IconButton(
          icon: const Icon(Icons.more_vert, color: textPrimary),
          onPressed: () {},
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ListenableBuilder(
              listenable: _dateTimeService,
              builder: (context, _) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      /*/// LOCATION STATUS
                      if (_currentPosition != null || _isLoadingLocation)
                        _LocationStatusCard(
                          position: _currentPosition,
                          isLoading: _isLoadingLocation,
                          onRefresh: _getCurrentLocation,
                        ),*/

                      _SectionHeader(
                        title: "Where in the city do you need a car?",
                        subtitle: "Select your pickup location",
                      ),

                      SectionCard(
                        child: GestureDetector(
                          onTap: _handleLocationTap,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _locationController.text.isEmpty
                                    ? Colors.grey[300]!
                                    : const Color(0xFF059669),
                                width: 1.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                _IconBubble(
                                  icon: Icons.location_on,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _locationController.text.isEmpty
                                            ? "Search location"
                                            : _locationController.text,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              _locationController.text.isEmpty
                                                  ? FontWeight.w400
                                                  : FontWeight.w600,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                      if (_locationController.text.isEmpty)
                                        Text(
                                          "Tap to select your location",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (_locationController.text.isNotEmpty)
                                  GestureDetector(
                                    onTap: () => setState(
                                        () => _locationController.clear()),
                                    child: Icon(Icons.close,
                                        size: 18, color: Colors.grey[400]),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      _SectionHeader(
                        title: "Pick your rental dates",
                        subtitle: null,
                      ),

                      SectionCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: TripDateSelect(
                                title: 'Trip Start',
                                date: _dateTimeService.tripStartDate,
                                time: _dateTimeService.tripStartTime,
                                onTap: () => _dateTimeService
                                    .selectStartDateTime(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TripDateSelect(
                                title: 'Trip End',
                                date: _dateTimeService.tripEndDate,
                                time: _dateTimeService.tripEndTime,
                                onTap: () =>
                                    _dateTimeService.selectEndDateTime(context),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// DELIVERY PICKUP
                      SectionCard(
                        child: AnimatedScale(
                          scale: _deliveryPickup ? 1.02 : 1,
                          duration: const Duration(milliseconds: 200),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              setState(
                                  () => _deliveryPickup = !_deliveryPickup);
                              HapticFeedback.selectionClick();
                            },
                            child: Row(
                              children: [
                                _Checkbox(_deliveryPickup),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Delivery & Pick-up",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "We'll deliver to your doorstep",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _IconBubble(
                                  icon: Icons.local_shipping_outlined,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      /// INFO
                      SectionCard(
                        child: Row(
                          children: [
                            _IconBubble(icon: Icons.verified_outlined),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Verified Cars",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "All vehicles are regularly inspected and maintained",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 50,
                      ),

                      /// SEARCH BUTTON
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SearchButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();

                            if (_locationController.text.isEmpty) {
                              _showError(
                                  context, "Please select a location first");
                              return;
                            }

                            if (!_dateTimeService.isValidDateRange) {
                              _showError(
                                  context, "Trip end must be after trip start");
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CarListScreen(
                                  selectedLocation: _locationController.text,
                                  startDate: _dateTimeService.tripStartDate,
                                  startTime: _dateTimeService.tripStartTime,
                                  endDate: _dateTimeService.tripEndDate,
                                  endTime: _dateTimeService.tripEndTime,
                                  deliveryPickup: _deliveryPickup,
                                  userPosition: _currentPosition,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

/*/// ---------- REUSABLE WIDGETS ----------

class _LocationStatusCard extends StatelessWidget {
  final Position? position;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _LocationStatusCard({
    required this.position,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF059669).withValues(alpha: 0.1),
            const Color(0xFF10B981).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF059669).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFF059669)),
                    ),
                  )
                : const Icon(
                    Icons.my_location,
                    color: Color(0xFF059669),
                    size: 20,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoading ? "Getting your location..." : "Location Active",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if (position != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${position!.latitude.toStringAsFixed(4)}, ${position!.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isLoading)
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, color: Color(0xFF059669)),
              iconSize: 20,
            ),
        ],
      ),
    );
  }
}*/

class SectionCard extends StatelessWidget {
  final Widget child;

  const SectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;

  const _IconBubble({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF059669).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: const Color(0xFF059669)),
    );
  }
}

class _Checkbox extends StatelessWidget {
  final bool value;

  const _Checkbox(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: value ? const Color(0xFF059669) : Colors.transparent,
        border: Border.all(
          color: value ? const Color(0xFF059669) : Colors.grey[400]!,
          width: 2,
        ),
      ),
      child:
          value ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
    );
  }
}

class _SearchButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SearchButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onPressed,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF059669), Color(0xFF10B981)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF059669).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, color: Colors.white),
              SizedBox(width: 12),
              Text(
                "SEARCH CARS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

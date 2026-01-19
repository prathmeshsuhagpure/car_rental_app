import 'package:car_rent_app/utils/theme.dart';
import 'package:car_rent_app/widgets/car_info_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/car_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/date_time_selection.dart';
import '../../widgets/full_screen_image_viewer.dart';
import '../payment/payment_screen.dart';

class CarDetailScreen extends StatefulWidget {
  final Car car;
  final DateTime? startDate;
  final DateTime? endDate;
  final TimeOfDay? endTime;
  final TimeOfDay? startTime;

  const CarDetailScreen({
    super.key,
    required this.car,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
  });

  @override
  _CarDetailScreenState createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  final DateTimeSelectionService _dateTimeService = DateTimeSelectionService();

  // Keys for each section to track their positions
  final List<GlobalKey> _sectionKeys = List.generate(6, (index) => GlobalKey());

  final List<String> _tabTitles = [
    'Photos',
    'Offers',
    'Reviews',
    'Location',
    'Benefits',
    'Policy'
  ];

  @override
  void initState() {
    super.initState();

    // Set the service values with the passed parameters
    if (widget.startDate != null) {
      _dateTimeService.tripStartDate = widget.startDate!;
    }
    if (widget.startTime != null) {
      _dateTimeService.tripStartTime = widget.startTime!;
    }
    if (widget.endDate != null) {
      _dateTimeService.tripEndDate = widget.endDate!;
    }
    if (widget.endTime != null) {
      _dateTimeService.tripEndTime = widget.endTime!;
    }

    _tabController = TabController(length: 6, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    int activeIndex = 0;

    for (int i = 0; i < _sectionKeys.length; i++) {
      final RenderBox? renderBox =
          _sectionKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        // Check if section is in viewport (adjust threshold as needed)
        if (position.dy <= 200 && position.dy > -300) {
          activeIndex = i;
        }
      }
    }

    // Update tab selection if different
    if (_tabController.index != activeIndex) {
      _tabController.animateTo(activeIndex);
    }
  }

  void _scrollToSection(int index) {
    final RenderBox? renderBox =
        _sectionKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final targetOffset =
          _scrollController.offset + position.dy - 200; // Adjust for header

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: darkGreen,
            elevation: 0,
            pinned: true,
            expandedHeight: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.black87, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${DateFormat('dd MMM yyyy').format(_dateTimeService.tripStartDate)} - ${DateFormat('dd MMM yyyy').format(_dateTimeService.tripEndDate)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "${_dateTimeService.tripStartTime.format(context)} - ${_dateTimeService.tripEndTime.format(context)}",
                  style: const TextStyle(
                    color: borderColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border,
                      color: Colors.black87, size: 22),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Vehicle added to wishlist"),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 1),
                    ));
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.share_outlined,
                      color: Colors.black87, size: 22),
                  onPressed: () {},
                ),
              ),
            ],
          ),

          // Car Info Card
          SliverToBoxAdapter(
            child: CarInfoCard(car: widget.car),
          ),

          // Sticky Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: false,
                indicator: BoxDecoration(
                  color: darkGreen,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: textPrimary,
                labelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                onTap: _scrollToSection,
                tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
              ),
            ),
          ),

          // Section Slivers
          ...List.generate(_tabTitles.length, (index) {
            return SliverToBoxAdapter(
              child: _buildSection(index, _tabTitles[index]),
            );
          }),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }


  Widget _buildSection(int index, String title) {
    return Container(
      key: _sectionKeys[index],
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          if (title == 'Photos')
            _buildPhotosTab()
          else if (title == 'Offers')
            _buildOffersTab()
          else if (title == 'Reviews')
            _buildReviewsTab()
          else if (title == 'Location')
            _buildLocationTab()
          else if (title == 'Benefits')
            _buildBenefitsTab()
          else if (title == 'Policy')
            _buildCancellationTab(),
        ],
      ),
    );
  }

  Widget _buildPhotosTab() {
    return Column(
      children: [
        // Main car image
        GestureDetector(
          onTap: widget.car.images.isNotEmpty
              ? () => _openImageViewer(context, 0)
              : null,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              image: widget.car.images.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(widget.car.images[0]),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: widget.car.images.isEmpty
                ? const Center(
              child: Icon(Icons.directions_car, size: 60, color: Colors.grey),
            )
                : null,
          ),
        ),
        const SizedBox(height: 16),

        // Photo grid - show only if there are images
        if (widget.car.images.isNotEmpty) ...[
          // If there are more than 1 image, show grid
          if (widget.car.images.length > 1)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: widget.car.images.length > 5 ? 4 : widget.car.images.length - 1,
              itemBuilder: (context, index) {
                int imageIndex = index + 1; // Skip first image as it's shown above
                bool isLastItem = index == 3 && widget.car.images.length > 5;

                return GestureDetector(
                  onTap: () {
                    _openImageViewer(context, imageIndex);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(widget.car.images[imageIndex]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: isLastItem
                        ? Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '+${widget.car.images.length - 4} more',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                        : null,
                  ),
                );
              },
            ),
        ],

        // Show message if no images
        if (widget.car.images.isEmpty)
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, size: 30, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No images available',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _openImageViewer(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          images: widget.car.images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Widget _buildOffersTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[50]!, Colors.orange[100]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_offer, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Special Discount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9A3412),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get 15% off on bookings above ₹2000',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(2, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: Color(0xFF10B981)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    index == 0
                        ? 'Free cancellation up to 24 hours'
                        : 'No hidden charges',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReviewsTab() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    "${widget.car.rating}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Based on 11 reviews',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF3B82F6),
                      child: Text(
                        'U${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Row(
                            children: List.generate(
                                5,
                                (i) => Icon(
                                      Icons.star,
                                      size: 14,
                                      color: i < 4
                                          ? Colors.amber
                                          : Colors.grey[300],
                                    ),),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  index == 0
                      ? 'Excellent car condition and very responsive host!'
                      : index == 1
                          ? 'Great experience, would book again.'
                          : 'Clean car and pickup was on time.',
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLocationTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 50, color: Colors.grey),
                SizedBox(height: 8),
                Text('Map View', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF3B82F6)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.car.distance,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'The exact location will be shared after booking confirmation.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
      ],
    );
  } /*Widget _buildLocationTab() {
  final double latitude = widget.car.latitude;
  final double longitude = widget.car.longitude;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: () async {
          final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(latitude, longitude),
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('car_location'),
                  position: LatLng(latitude, longitude),
                ),
              },
              zoomControlsEnabled: false,
              liteModeEnabled: true, // Faster and lightweight
              onTap: (_) async {
                final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                }
              },
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF3B82F6)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.car.distance,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      const Text(
        'The exact location will be shared after booking confirmation.',
        style: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14,
        ),
      ),
    ],
  );
}*/

  Widget _buildBenefitsTab() {
    final benefits = [
      {
        'icon': Icons.wifi,
        'title': 'Free WiFi',
        'desc': 'Stay connected on the go'
      },
      {
        'icon': Icons.local_gas_station,
        'title': 'Fuel Included',
        'desc': 'No need to worry about fuel'
      },
      {
        'icon': Icons.ac_unit,
        'title': 'Air Conditioning',
        'desc': 'Climate controlled comfort'
      },
      {
        'icon': Icons.security,
        'title': 'Insurance Covered',
        'desc': 'Comprehensive coverage included'
      },
      {
        'icon': Icons.support_agent,
        'title': '24/7 Support',
        'desc': 'Round the clock assistance'
      },
    ];

    return Column(
      children: benefits.map((benefit) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  benefit['icon'] as IconData,
                  color: const Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      benefit['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      benefit['desc'] as String,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCancellationTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600]),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Free cancellation up to 24 hours before trip',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Terms and Conditions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '• Valid driving license required\n'
          '• Security deposit will be collected\n'
          '• Vehicle should be returned with same fuel level\n'
          '• Any damages will be charged separately\n'
          '• Late return charges apply after grace period',
          style: TextStyle(
            color: Color(0xFF475569),
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price per day',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${widget.car.pricePerDay}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        car: widget.car,
                        user: currentUser!,
                        startDate: _dateTimeService.tripStartDate,
                        endDate: _dateTimeService.tripEndDate,
                        pickupLocation: widget.car.location,
                        dropoffLocation: widget.car.location,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: const Color(0xFFF8FAFC), // Match background color
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}


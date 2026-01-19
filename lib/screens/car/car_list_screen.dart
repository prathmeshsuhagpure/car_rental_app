import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/car_provider.dart';
import '../../utils/date_time_selection.dart';
import '../../utils/helper.dart';
import '../../utils/location_selector.dart';
import '../../utils/theme.dart';
import '../../widgets/car_card.dart';
import '../../widgets/custom_app_bar.dart';

class CarListScreen extends StatefulWidget {
  final String? selectedLocation;
  final DateTime? startDate;
  final TimeOfDay? startTime;
  final DateTime? endDate;
  final TimeOfDay? endTime;
  final bool? deliveryPickup;

  const CarListScreen({
    super.key,
    this.selectedLocation,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.deliveryPickup,
  });

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late DateTimeSelectionService _dateTimeService;
  final TextEditingController _locationController = TextEditingController();

  String _searchQuery = '';
  final String _selectedCategory = '';
  String _selectedSort = 'Default';

  String _currentLocation = '';
  //bool _currentDeliveryPickup = false;

  final List<Map<String, dynamic>> _filters = [
    {'label': 'Filters', 'icon': Icons.tune, 'selected': false},
    {
      'label': 'Zoomcar Assured',
      'icon': Icons.verified_user,
      'selected': false
    },
    {
      'label': 'Home Delivery',
      'icon': Icons.local_shipping_outlined,
      'selected': false
    },
    {'label': 'Guest Favourite', 'icon': Icons.star_rounded, 'selected': true},
  ];

  final List<String> _sortOptions = [
    'Default',
    'Price: Low to High',
    'Price: High to Low',
    'Popularity',
    'Newest First'
  ];

  @override
  void initState() {
    super.initState();
    _dateTimeService = Provider.of<DateTimeSelectionService>(context, listen: false);

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

    _currentLocation = widget.selectedLocation ?? 'Select Location';
    //_currentDeliveryPickup = widget.deliveryPickup ?? false;

    _searchController = TextEditingController();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    // Load cars when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CarProvider>(context, listen: false).loadCars();
    });
  }

  Future<void> _handleLocationTap() async {
    final selectedLocation =
    await showLocationSuggestions(context, locationSuggestions);
    if (selectedLocation != null && selectedLocation.isNotEmpty) {
      setState(() {
        _currentLocation = selectedLocation;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _toggleFilter(int index) {
    setState(() {
      _filters[index]['selected'] = !_filters[index]['selected'];
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ..._sortOptions.map((option) => ListTile(
              title: Text(option),
              trailing: _selectedSort == option
                  ? const Icon(Icons.check, color: Color(0xFF2E7D32))
                  : null,
              onTap: () {
                setState(() {
                  _selectedSort = option;
                });
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Select Car",
        iconButton: IconButton(
          icon: const Icon(Icons.more_horiz, color: textPrimary),
          onPressed: () {},
        ),
      ),
      backgroundColor: const Color(0xFFF8FFFE),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Fixed Location Header - This stays at the top always
                _buildLocationHeader(),
                // Expanded scrollable content
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // Non-sticky title section
                      SliverToBoxAdapter(
                        child: _buildTitleSection(),
                      ),
                      // Sticky header containing search and filters
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _StickyHeaderDelegate(
                          child: Container(
                            color: const Color(0xFFF8FFFE),
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              children: [
                                _buildSearchSection(),
                                _buildFilterChips(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Cars list
                      _buildCarsList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationHeader() {
    return ChangeNotifierProvider.value(
        value: _dateTimeService,
        child: Consumer<DateTimeSelectionService>(
          builder: (context, dateTimeService, child) {
            return Container(
              margin: const EdgeInsets.all(16),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(16),
                shadowColor: Colors.black.withOpacity(0.1),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFF2E7D32),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _handleLocationTap();
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cars available at',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _currentLocation.length > 30
                                    ? '${_currentLocation.substring(0, 30)}....'
                                    : _currentLocation,
                                style: TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          dateTimeService.selectStartDateTime(context);
                        },
                        child: _buildDateTimeChip(
                          formatDateTime(
                            dateTimeService.tripStartDate,
                            dateTimeService.tripStartTime,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 20,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          dateTimeService.selectEndDateTime(context);
                        },
                        child: _buildDateTimeChip(
                          formatDateTime(
                            dateTimeService.tripEndDate,
                            dateTimeService.tripEndTime,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }

  Widget _buildDateTimeChip(String dateTime) {
    final parts = dateTime.split('|');
    final date = parts[0];
    final time = parts[1];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF2E7D32).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            date,
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
            ).createShader(bounds),
            child: const Text(
              'Daily Drives',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Everyday bookings made quick and easy',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search for model, features, etc',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            shadowColor: Colors.black.withOpacity(0.1),
            child: InkWell(
              onTap: _showSortBottomSheet,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_rounded,
                      color: Colors.grey[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sort',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              index: index,
              icon: filter['icon'],
              label: filter['label'],
              isSelected: filter['selected'],
              onTap: _toggleFilter,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCarsList() {
    return Consumer<CarProvider>(
      builder: (context, carProvider, child) {
        if (carProvider.isLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading cars...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (carProvider.error != null) {
          return SliverFillRemaining(
            child: _buildErrorState(carProvider),
          );
        }

        List<dynamic> filteredCars = _getFilteredCars(carProvider);

        if (filteredCars.isEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(),
          );
        }

        return _buildCarsGrid(filteredCars);
      },
    );
  }

  List<dynamic> _getFilteredCars(CarProvider carProvider) {
    List<dynamic> filteredCars = carProvider.cars;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredCars = carProvider.searchCars(_searchQuery);
    }

    // Apply category filter
    if (_selectedCategory.isNotEmpty) {
      filteredCars = carProvider.filterByCategory(_selectedCategory);
    }

    return filteredCars;
  }

  Widget _buildErrorState(CarProvider carProvider) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              carProvider.error!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => carProvider.loadCars(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_rounded,
                size: 48,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No cars found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarsGrid(List<dynamic> cars) {
    return Consumer<DateTimeSelectionService>(
      builder: (context, dateTimeService, child) {
        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final car = cars[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CarCard(
                      car: car,
                      index: index,
                      startDate: dateTimeService.tripStartDate,
                      endDate: dateTimeService.tripEndDate,
                      startTime: dateTimeService.tripStartTime,
                      endTime: dateTimeService.tripEndTime,
                    ),
                  ),
                );
              },
              childCount: cars.length,
            ),
          ),
        );
      },
    );
  }
}

// Custom delegate for sticky header - Updated for search and filters
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 130; // Minimum height when collapsed (search + filters)

  @override
  double get maxExtent => 130; // Maximum height when expanded

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Function(int) onTap;
  final int index;

  const FilterChip({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              colors: [Colors.orange[400]!, Colors.orange[600]!],
            )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey[300]!,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Colors.orange.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
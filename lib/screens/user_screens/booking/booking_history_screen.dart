import 'package:car_rent_app/utils/theme.dart';
import 'package:car_rent_app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/booking_model.dart';
import '../../../providers/booking_provider.dart';
import 'booking_history_card.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String selectedFilter = 'All';

  final List<String> filterOptions = ['All', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadUserBookings();
    });
  }

  List<BookingModel> _getFilteredBookings(List<BookingModel> bookings) {
    if (selectedFilter == 'All') return bookings;

    return bookings.where((booking) {
      switch (selectedFilter) {
        case 'Completed':
          return booking.isCompleted;
        case 'Cancelled':
          return booking.isCancelled;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: "Booking History",
        iconButton: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<BookingProvider>().loadUserBookings(),
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          final filteredBookings =
              _getFilteredBookings(bookingProvider.bookings);

          return Column(
            children: [
              Container(
                height: 60,
                color: Colors.white,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filterOptions.length,
                  itemBuilder: (context, index) {
                    final filter = filterOptions[index];
                    final isSelected = selectedFilter == filter;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedFilter = filter;
                          });
                        },
                        selectedColor: primaryGreen.withValues(alpha: 0.3),
                        checkmarkColor: primaryGreen,
                        labelStyle: TextStyle(
                          color: isSelected ? primaryGreen : Colors.grey[800],
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: bookingProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: primaryGreen,
                        ),
                      )
                    : bookingProvider.error != null
                        ? _buildErrorState(bookingProvider.error!)
                        : filteredBookings.isEmpty
                            ? _buildEmptyState()
                            : RefreshIndicator(
                                color: primaryGreen,
                                onRefresh: () =>
                                    bookingProvider.loadUserBookings(),
                                child: ListView.builder(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: filteredBookings.length,
                                  itemBuilder: (context, index) {
                                    final booking = filteredBookings[index];
                                    return BookingHistoryCard(
                                      booking: booking,
                                      onCancelBooking: () => _onCancelBooking(
                                        booking,
                                        bookingProvider,
                                      ),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<BookingProvider>().loadUserBookings(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (selectedFilter) {
      case 'Completed':
        message = 'No completed bookings found';
        icon = Icons.check_circle_outline;
        break;
      case 'Cancelled':
        message = 'No cancelled bookings found';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = 'No bookings found';
        icon = Icons.history;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your bookings will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Book a Car'),
          ),
        ],
      ),
    );
  }

  void _onCancelBooking(BookingModel booking, BookingProvider bookingProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel booking ${booking.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'No',
              style: TextStyle(color: primaryGreen),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelBooking(booking, bookingProvider);
            },
            style: ElevatedButton.styleFrom(backgroundColor: darkGreen),
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(
      BookingModel booking, BookingProvider bookingProvider) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: primaryGreen,
          ),
        ),
      );

      await bookingProvider.cancelBooking(booking.id);
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      Navigator.pop(context);

      _showSuccessSnackBar('Booking cancelled successfully');

      bookingProvider.loadUserBookings();
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Failed to cancel booking: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}

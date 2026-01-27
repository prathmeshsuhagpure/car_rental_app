/*import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import 'car_info_card.dart';
import '../models/car_model.dart';
import '../../utils/date_time_selection.dart';

class BookingCard extends StatefulWidget {
  final BookingModel booking;
  final Car car;
  final Future<void> Function(BookingModel booking) onCancel;
  final Future<void> Function(BookingModel booking)? onPay;
  final VoidCallback? onViewDetails;


  const BookingCard({
    super.key,
    required this.booking,
    required this.onCancel,
    this.onPay,
    this.onViewDetails,
    required this.car,
  });

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;
  final DateTimeSelectionService _dateTimeService = DateTimeSelectionService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Fixed: Made this a getter method instead of orphaned code
  Color get _statusColor {
    switch (widget.booking.bookingStatus.toLowerCase()) {
      case 'confirmed' || "active":
        return Colors.green;
      case 'pending' || "inactive":
        return Colors.orange;
      case 'cancelled' || "deleted" || "expired":
        return Colors.red;
      case 'completed' :
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData get _statusIcon {
    switch (widget.booking.bookingStatus.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                  const Color(0xFF2A2A2A),
                  const Color(0xFF1E1E1E),
                ]
                    : [
                  Colors.white,
                  const Color(0xFFFAFAFA),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.8),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onViewDetails,
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      widget.car != null
                          ? CarInfoCard(car: widget.car)
                          : _buildNoCarInfo(),
                      const SizedBox(height: 20),
                      _buildBookingDetails(),
                      const SizedBox(height: 24),
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _statusColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _statusIcon,
                size: 16,
                color: _statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                (widget.booking.bookingStatus.toUpperCase()), // Fixed null safety
                style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Text(
          'ID: ${widget.booking.id}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNoCarInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Car information not available',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails() {
    final totalAmount = widget.car.originalPrice * widget.booking.durationInDays;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            Icons.calendar_today_outlined,
            'Trip Start Date',
            widget.booking.formattedStartDate,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.calendar_today_outlined,
            'Trip End Date',
            widget.booking.formattedEndDate,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.calendar_today_outlined,
            'Trip Duration',
            _dateTimeService.durationFormatted,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.attach_money,
            'Total Amount (Excluding Fees*)',
            '₹ ${totalAmount.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        if (widget.onPay != null &&
            widget.booking.bookingStatus.toLowerCase() != 'cancelled')
          Expanded(
            child: _buildModernButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                setState(() => _isLoading = true);
                try {
                  await widget.onPay!(widget.booking);
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              label: 'Pay Now',
              icon: Icons.payment,
              isPrimary: true,
              isLoading: _isLoading,
            ),
          ),
        if (widget.onPay != null &&
            widget.booking.bookingStatus.toLowerCase() != 'cancelled')
          const SizedBox(width: 12),
        Expanded(
          child: _buildModernButton(
            onPressed: widget.booking.bookingStatus.toLowerCase() == 'cancelled'
                ? null
                : () async {
              final shouldCancel = await _showCancelDialog(context);
              if (shouldCancel == true) {
                setState(() => _isLoading = true);
                try {
                  await widget.onCancel(widget.booking);
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              }
            },
            label: widget.booking.bookingStatus.toLowerCase() == 'cancelled'
                ? 'Cancelled'
                : 'Cancel',
            icon: widget.booking.bookingStatus.toLowerCase() == 'cancelled'
                ? Icons.block
                : Icons.cancel_outlined,
            isPrimary: false,
            isDestructive: widget.booking.bookingStatus.toLowerCase() != 'cancelled',
          ),
        ),
      ],
    );
  }

  Widget _buildModernButton({
    required VoidCallback? onPressed,
    required String label,
    required IconData icon,
    required bool isPrimary,
    bool isDestructive = false,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    Color getButtonColor() {
      if (!isEnabled) return Colors.grey;
      if (isDestructive) return Colors.red;
      if (isPrimary) return theme.colorScheme.primary;
      return Colors.grey[600]!;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: isPrimary ? Colors.white : getButtonColor(),
          ),
        )
            : Icon(
          icon,
          size: 18,
          color: isPrimary ? Colors.white : getButtonColor(),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isPrimary ? Colors.white : getButtonColor(),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? getButtonColor()
              : getButtonColor().withValues(alpha: 0.1),
          foregroundColor: isPrimary ? Colors.white : getButtonColor(),
          elevation: isPrimary ? 2 : 0,
          shadowColor: getButtonColor().withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: getButtonColor().withValues(alpha: isPrimary ? 0 : 0.3),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showCancelDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Booking'),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Booking'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }
}*/


import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/car_model.dart';
import 'car_info_card.dart';

class BookingCard extends StatefulWidget {
  final BookingModel booking;
  final Car? car;
  final Future<void> Function(BookingModel booking) onCancel;
  final Future<void> Function(BookingModel booking)? onPay;
  final VoidCallback? onViewDetails;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onCancel,
    this.onPay,
    this.onViewDetails,
    this.car,
  });

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ================= STATUS HELPERS =================

  Color get _statusColor {
    switch (widget.booking.bookingStatus) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData get _statusIcon {
    switch (widget.booking.bookingStatus) {
      case 'active':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.schedule;
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final car = widget.booking.car ?? widget.car;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (_, __) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF2A2A2A), Color(0xFF1E1E1E)]
                    : const [Colors.white, Color(0xFFFAFAFA)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: widget.onViewDetails,
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 20),
                      car != null ? CarInfoCard(car: car) : _buildNoCarInfo(),
                      const SizedBox(height: 20),
                      _buildBookingDetails(car),
                      const SizedBox(height: 24),
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final bookingId = widget.booking.id;
    final shortId = bookingId.length >= 6
        ? bookingId.substring(0, 6).toUpperCase()
        : bookingId.isNotEmpty
        ? bookingId.toUpperCase()
        : '—';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _statusColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(_statusIcon, size: 16, color: _statusColor),
              const SizedBox(width: 6),
              Text(
                widget.booking.bookingStatus.toUpperCase(),
                style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          'ID: $shortId',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildNoCarInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text('Car information not available'),
    );
  }

  Widget _buildBookingDetails(Car? car) {
    final totalAmount = widget.booking.amount * widget.booking.durationInDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _detailRow('Start Date', widget.booking.formattedStartDate),
          _detailRow('End Date', widget.booking.formattedEndDate),
          _detailRow('Duration', '${widget.booking.durationInDays} day(s)'),
          _detailRow('Total Amount', '₹${totalAmount.toStringAsFixed(0)}'),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        if (widget.onPay != null && widget.booking.paymentStatus == 'pending')
          Expanded(
            child: _button(
              label: 'Pay Now',
              color: Colors.blue,
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      await widget.onPay!(widget.booking);
                      if (mounted) setState(() => _isLoading = false);
                    },
            ),
          ),
        if (widget.booking.bookingStatus != 'cancelled')
          const SizedBox(width: 12),
        if (widget.booking.bookingStatus != 'cancelled')
          Expanded(
            child: _button(
              label: 'Cancel',
              color: Colors.red,
              onPressed: () async {
                final confirm = await _showCancelDialog(context);
                if (confirm == true) {
                  setState(() => _isLoading = true);
                  await widget.onCancel(widget.booking);
                  if (mounted) setState(() => _isLoading = false);
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _button({
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(label),
    );
  }

  Future<bool?> _showCancelDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PriceBreakupSheet extends StatelessWidget {
  final String currency;
  final double amount;
  final double gst;
  final double platformFee;
  final double securityDeposit;
  final double totalAmount;

  const PriceBreakupSheet({
    super.key,
    required this.currency,
    required this.amount,
    required this.gst,
    required this.platformFee,
    required this.securityDeposit,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D57).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Color(0xFF2E7D57),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Price Breakdown',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),

          // Price breakdown items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildBreakdownItem(
                  'Rental Amount',
                  '$currency ${amount.toStringAsFixed(2)}',
                  Icons.directions_car,
                ),
                const SizedBox(height: 16),

                _buildBreakdownItem(
                  'GST (18%)',
                  '$currency ${gst.toStringAsFixed(2)}',
                  Icons.account_balance,
                ),
                const SizedBox(height: 16),

                _buildBreakdownItem(
                  'Platform Fee',
                  '$currency ${platformFee.toStringAsFixed(2)}',
                  Icons.business,
                ),
                const SizedBox(height: 16),

                _buildBreakdownItem(
                  'Security Deposit \nRefundable on car return',
                  '$currency ${securityDeposit.toStringAsFixed(2)}',
                  Icons.verified_user,
                ),

                const SizedBox(height: 20),
                Container(height: 1, color: Colors.grey[200]),
                const SizedBox(height: 20),

                _buildBreakdownItem(
                  'Total Amount',
                  '$currency ${totalAmount.toStringAsFixed(2)}',
                  Icons.payment,
                  isHighlighted: true,
                ),
              ],
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Proceed with payment
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D57),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue Payment',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String title, String amount, IconData icon,
      {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? const Color(0xFF2E7D57).withValues(alpha: 0.08)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? Border.all(
          color: const Color(0xFF2E7D57).withValues(alpha: 0.2),
          width: 1,
        )
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? const Color(0xFF2E7D57).withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isHighlighted
                  ? const Color(0xFF2E7D57)
                  : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                isHighlighted ? FontWeight.w600 : FontWeight.w500,
                color: isHighlighted
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isHighlighted ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isHighlighted
                  ? const Color(0xFF2E7D57)
                  : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

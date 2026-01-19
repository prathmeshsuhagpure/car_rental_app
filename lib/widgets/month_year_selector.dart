import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> showCustomMonthYearPicker(BuildContext context, TextEditingController expiryDateController) async {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  // Modern color scheme
  const Color primaryGreen = Color(0xFF2E7D32);
  const Color lightGreen = Color(0xFF4CAF50);
  const Color backgroundColor = Color(0xFFF8FAF9);
  const Color cardBackground = Colors.white;
  const Color textPrimary = Color(0xFF1A1A1A);
  const Color textSecondary = Color(0xFF666666);
  const Color borderColor = Color(0xFFE0E0E0);

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: cardBackground,
            elevation: 10,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.calendar_today_outlined,
                          color: primaryGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Expiry Date',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Choose month and year',
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Date Selection Section
                  Row(
                    children: [
                      // Month Selection
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Month',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: DropdownButton<int>(
                                value: selectedMonth,
                                isExpanded: true,
                                underline: const SizedBox(),
                                icon: Icon(Icons.keyboard_arrow_down, color: primaryGreen),
                                style: const TextStyle(
                                  color: textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: List.generate(12, (index) {
                                  final month = index + 1;
                                  final monthNames = [
                                    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                                  ];
                                  return DropdownMenuItem(
                                    value: month,
                                    child: Text(
                                      '${month.toString().padLeft(2, '0')} - ${monthNames[index]}',
                                      style: const TextStyle(
                                        color: textPrimary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedMonth = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Year Selection
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Year',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: DropdownButton<int>(
                                value: selectedYear,
                                isExpanded: true,
                                underline: const SizedBox(),
                                icon: Icon(Icons.keyboard_arrow_down, color: primaryGreen),
                                style: const TextStyle(
                                  color: textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: List.generate(20, (index) {
                                  int year = DateTime.now().year + index;
                                  return DropdownMenuItem(
                                    value: year,
                                    child: Text(
                                      '$year',
                                      style: const TextStyle(
                                        color: textPrimary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedYear = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Selected Date Preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryGreen.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${selectedMonth.toString().padLeft(2, '0')}/${selectedYear.toString().substring(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: borderColor),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final formatted =
                                '${selectedMonth.toString().padLeft(2, '0')}/${selectedYear.toString().substring(2)}';
                            expiryDateController.text = formatted;
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
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


class ExpiryDateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    // Remove all non-digits
    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    // Format as MM/YY
    if (text.length >= 3) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

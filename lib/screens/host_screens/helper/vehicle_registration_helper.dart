import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildVehicleRegTextField(
  TextEditingController controller,
  IconData icon,
) {
  return TextFormField(
    controller: controller,
    textCapitalization: TextCapitalization.characters,
    maxLength: 10,
    // Old plates can be longer
    decoration: InputDecoration(
      labelText: 'Vehicle Registration Number',
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2196F3)),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      counterText: '',
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter Vehicle Registration Number';
      }

      final regExpOld =
          RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}$'); // Old plates
      final regExpBHNew =
          RegExp(r'^[0-9]{2}BH[0-9]{4}[A-Z]{1}$'); // BH new plates

      if (!regExpOld.hasMatch(value.toUpperCase()) &&
          !regExpBHNew.hasMatch(value.toUpperCase())) {
        return 'Invalid Vehicle Registration Number';
      }
      return null;
    },
    inputFormatters: [
      UpperCaseTextFormatter(),
      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
    ],
  );
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(), // Convert to uppercase
      selection: newValue.selection,
    );
  }
}

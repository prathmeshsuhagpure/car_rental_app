import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/country_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/helper.dart';
import 'otp_screen.dart';
import 'email_signup_screen.dart'; // Add this import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  late CountryCode _selectedCountry;
  bool _isLoading = false;
  bool _isHost = false;

  final apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _selectedCountry = countryCodes.firstWhere((c) => c.code == '+91');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildLogo(),
                  const SizedBox(height: 80),
                  _buildLoginForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF059669),
            Color(0xFF10B981),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Column(
        children: [
          Text(
            'SAVAARI',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
          Text(
            'CAR RENTALS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF334155).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your phone number to continue',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 40),
          _buildCountryCodeDropdown(),
          const SizedBox(height: 24),
          _buildPhoneInput(),
          const SizedBox(height: 24),
          _buildHostCheckbox(),
          const SizedBox(height: 32),
          _buildSubmitButton(),
          const SizedBox(height: 24),
          _buildDivider(), // Add divider
          const SizedBox(height: 24),
          _buildEmailLoginLink(), // Add email login link
          const SizedBox(height: 24),
          _buildTermsText(),
        ],
      ),
    );
  }

  Widget _buildCountryCodeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        border: Border.all(color: const Color(0xFF475569), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CountryCode>(
          value: _selectedCountry,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          dropdownColor: const Color(0xFF334155),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          items: countryCodes
              .map<DropdownMenuItem<CountryCode>>((CountryCode country) {
            return DropdownMenuItem<CountryCode>(
              value: country,
              child: Row(
                children: [
                  Text(
                    country.flag,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${country.code} | ${country.country}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (CountryCode? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCountry = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        border: Border.all(color: const Color(0xFF475569), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: InputDecoration(
          hintText: 'Enter your phone number',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixText: '${_phoneController.text.length}/10',
          suffixStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildHostCheckbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF334155).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isHost ? const Color(0xFF059669) : const Color(0xFF475569),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: _isHost,
              onChanged: (bool? value) {
                setState(() {
                  _isHost = value ?? false;
                });
              },
              checkColor: Colors.white,
              activeColor: const Color(0xFF059669),
              side: const BorderSide(color: Colors.white70, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Login as Host',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Access host dashboard and manage your vehicles',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (_phoneController.text.length == 10 && !_isLoading)
            ? () async {
          setState(() {
            _isLoading = true;
          });

          final fullPhone =
              '${_selectedCountry.code}${_phoneController.text}';

          final result = await authProvider.sendOtpLogin(fullPhone);

          setState(() {
            _isLoading = false;
          });

          if (result["success"]) {
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPScreen(
                  phoneNumber: fullPhone,
                  isHost: _isHost,
                ),
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("OTP sent successfully"),
                backgroundColor: Color(0xFF059669),
              ),
            );
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Failed to send OTP"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF059669),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          disabledBackgroundColor: const Color(0xFF475569),
          shadowColor: const Color(0xFF059669).withValues(alpha: 0.5),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          _isHost ? 'Continue as Host' : 'Submit',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Add this new method for the divider
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[600],
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey[600],
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailLoginLink() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmailSignupScreen(),
            ),
          );
        },
        icon: const Icon(
          Icons.email_outlined,
          color: Color(0xFF059669),
        ),
        label: const Text(
          'Continue with Email',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Color(0xFF059669),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: const Color(0xFF059669).withValues(alpha: 0.1),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Center(
      child: Text(
        'By continuing, you agree to our Terms of Service\nand Privacy Policy',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[400],
          height: 1.5,
        ),
      ),
    );
  }
}
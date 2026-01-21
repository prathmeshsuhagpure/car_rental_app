import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../home/host_home_screen.dart';

class EmailSignupScreen extends StatefulWidget {
  const EmailSignupScreen({super.key});

  @override
  EmailSignupScreenState createState() => EmailSignupScreenState();
}

class EmailSignupScreenState extends State<EmailSignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isLoading = false;
  bool _isHost = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoginMode = true;

  bool get _isFormValid {
    if (_isLoginMode) {
      return _emailController.text.trim().isNotEmpty &&
          _passwordController.text.trim().isNotEmpty;
    } else {
      return _nameController.text.trim().isNotEmpty &&
          _emailController.text.trim().isNotEmpty &&
          _passwordController.text.trim().isNotEmpty &&
          _confirmPasswordController.text.trim().isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    return password.length >= 6;
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
                  const SizedBox(height: 40),
                  _buildLogo(),
                  const SizedBox(height: 60),
                  _buildAuthForm(),
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

  Widget _buildAuthForm() {
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
          Text(
            _isLoginMode ? 'Welcome Back' : 'Create Account',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isLoginMode
                ? 'Login with your email and password'
                : 'Sign up to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 40),
          if (!_isLoginMode) ...[
            _buildNameInput(),
            const SizedBox(height: 24),
          ],
          _buildEmailInput(),
          const SizedBox(height: 24),
          _buildPasswordInput(),
          if (!_isLoginMode) ...[
            const SizedBox(height: 24),
            _buildConfirmPasswordInput(),
          ],
          const SizedBox(height: 24),
          _buildHostCheckbox(),
          const SizedBox(height: 32),
          _buildSubmitButton(),
          const SizedBox(height: 24),
          _buildToggleAuthMode(),
          const SizedBox(height: 16),
          _buildBackToPhoneLogin(),
        ],
      ),
    );
  }

  Widget _buildNameInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        border: Border.all(color: const Color(0xFF475569), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _nameController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Full Name',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildEmailInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        border: Border.all(color: const Color(0xFF475569), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _emailController,
        onChanged: (_) => setState(() {}),
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Email Address',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        border: Border.all(color: const Color(0xFF475569), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _passwordController,
        onChanged: (_) => setState(() {}),
        obscureText: _obscurePassword,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        border: Border.all(color: const Color(0xFF475569), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _confirmPasswordController,
        onChanged: (_) => setState(() {}),
        obscureText: _obscureConfirmPassword,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Confirm Password',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
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
                Text(
                  _isLoginMode ? 'Login as Host' : 'Register as Host',
                  style: const TextStyle(
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
        onPressed: (_isFormValid && !_isLoading)
            ? () async {
                setState(() {
                  _isLoading = true;
                });

                try {
                  Map<String, dynamic>? result;

                  if (_isLoginMode) {
                    result = await authProvider.loginWithEmail(
                      _emailController.text.trim(),
                      _passwordController.text,
                      _isHost,
                    );
                  } else {
                    result = await authProvider.signupWithEmail(
                      _nameController.text.trim(),
                      _emailController.text.trim(),
                      _passwordController.text,
                      _isHost,
                    );
                  }

                  if (!mounted) return;

                  setState(() {
                    _isLoading = false;
                  });

                  if (result == null || result['success'] != true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result?['message'] ??
                              (_isLoginMode ? "Login failed" : "Signup failed"),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result['message'] ??
                            (_isLoginMode
                                ? "Login successful"
                                : "Account created successfully"),
                      ),
                      backgroundColor: const Color(0xFF059669),
                    ),
                  );

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => result?['isHost'] == true
                          ? const HostHomeScreen()
                          : const UserHomeScreen(),
                    ),
                    (route) => false,
                  );
                } catch (e) {
                  if (!mounted) return;

                  setState(() {
                    _isLoading = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: ${e.toString()}"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF059669),
          disabledBackgroundColor: const Color(0xFF475569),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                _isLoginMode
                    ? (_isHost ? 'Login as Host' : 'Login')
                    : (_isHost ? 'Sign Up as Host' : 'Sign Up'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildToggleAuthMode() {
    return Center(
      child: TextButton(
        onPressed: () {
          setState(() {
            _isLoginMode = !_isLoginMode;
            _clearAuthFields();
          });
        },
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            children: [
              TextSpan(
                text: _isLoginMode
                    ? "Don't have an account? "
                    : "Already have an account? ",
              ),
              const TextSpan(
                text: '',
                style: TextStyle(
                  color: Color(0xFF059669),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackToPhoneLogin() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.arrow_back,
              size: 18,
              color: Color(0xFF059669),
            ),
            const SizedBox(width: 8),
            Text(
              'Back to Phone Login',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _clearAuthFields() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _nameController.clear();
  }
}

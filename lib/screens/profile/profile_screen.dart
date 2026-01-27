import 'package:car_rent_app/screens/profile/update_profile_screen.dart';
import 'package:car_rent_app/services/api_endpoints.dart';
import 'package:car_rent_app/utils/theme.dart';
import 'package:car_rent_app/widgets/verify_profile_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final ApiConstants _apiConstants = ApiConstants();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  void _initUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool isHost = authProvider.isHost;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            style: ElevatedButton.styleFrom(
              backgroundColor: isHost? Colors.blue[50] : accentGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          SizedBox(width: 25,),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isHost? Colors.red : primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != true) return;

    if (!mounted) return;
    await authProvider.logout();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/loginWithEmail',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoggingOut == true) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider == null || authProvider.user == null) {
      return const SizedBox.shrink();
    }

    final user = authProvider.user!.isHost;

    final bool isHost = user;
    return Scaffold(
      backgroundColor: lightGray,
      body: FutureBuilder<String?>(
        future: _secureStorage.read(key: 'auth_token'),
        builder: (context, snapshot) {
          final token = snapshot.data;
          return Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.user;

              if (token == null && user == null) {
                return _buildNoTokenNoUserUI(context);
              }

              if (token != null && user == null) {
                return _buildTokenNoUserUI(context);
              }

              return isHost
                  ? _buildFullHostProfile(context, user!)
                  : _buildFullProfileUI(context, user!);
            },
          );
        },
      ),
    );
  }

  Widget _buildNoTokenNoUserUI(BuildContext context) {
    return Container(
      color: lightGray,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: accentGreen,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child:
                        const Icon(Icons.person, size: 40, color: primaryGreen),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Login or Sign up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _infoMessage(
                      "You need to Login to view your profile details."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenNoUserUI(BuildContext context) {
    return Container(
      color: lightGray,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(Icons.person_outline,
                        size: 40, color: Colors.orange.shade700),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UpdateProfileScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Complete Your Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _infoMessage(
                      "We found your session. Please complete your profile."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullProfileUI(BuildContext context, User user) {
    return Scaffold(
      body: Column(
        children: [
          // Fixed Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: darkGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/user_home');
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: user.profilePicture != null &&
                                  user.profilePicture!.isNotEmpty
                              ? Image.network(
                                  _apiConstants.imageUrl + user.profilePicture!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.name ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const UpdateProfileScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    Center(
                      child: Text(
                        user.phoneNumber ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    user.isVerified
                        ? _infoMessage("Profile is Verified")
                        : _infoMessage("Please verify your profile"),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _modernSectionContainer([
                    buildModernTileSection(
                        context,
                        "Offers",
                        "Amazing offers for your next trip",
                        Icons.local_offer,
                        () {}),
                    buildModernTileSection(
                        context,
                        "Refer and Earn",
                        "Refer friends & earn up to ₹11,000",
                        Icons.group_add,
                        () {}),
                    buildModernTileSection(context, "Change City", "Bangalore",
                        Icons.location_on, () {}),
                  ]),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "More",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: darkGray,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _modernSectionContainer([
                    buildModernTileSection(
                        context, "Policies", "", Icons.description, () {}),
                    buildModernTileSection(
                        context, "Help & Support", "", Icons.headphones, () {}),
                    buildModernTileSection(
                        context, "Rate Us", "", Icons.thumb_up, () {}),
                    buildModernTileSection(
                        context, "Settings", "", Icons.settings, () {}),
                  ]),
                  const SizedBox(height: 16),
                  _modernSectionContainer([
                    buildModernTileSection(context, "Log out", "",
                        Icons.exit_to_app, _handleLogout,
                        isLogout: true),
                  ]),
                  const SizedBox(height: 20),
                  Text(
                    "Version 17.2.0",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullHostProfile(BuildContext context, User user) {
    return Scaffold(
      body: Column(
        children: [
          // Fixed Header for Host
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF9C27B0)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/host_home');
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: user.profilePicture != null &&
                                  user.profilePicture!.isNotEmpty
                              ? Image.network(
                                  _apiConstants.imageUrl + user.profilePicture!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.name ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const UpdateProfileScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    Center(
                      child: Text(
                        user.phoneNumber ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _infoMessage("Keep your host profile updated."),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _modernSectionContainer([
                    buildModernTileSection(
                        context,
                        "My Listings",
                        "View and manage your properties",
                        Icons.home_work,
                        () {}),
                    buildModernTileSection(context, "Bookings Received",
                        "All guest bookings", Icons.calendar_today, () {}),
                    buildModernTileSection(context, "Earnings",
                        "Your earnings summary", Icons.attach_money, () {}),
                  ]),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "More",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _modernSectionContainer([
                    buildModernTileSection(context, "Reviews",
                        "View guest feedback", Icons.rate_review, () {}),
                    buildModernTileSection(
                        context, "Host Policies", "", Icons.description, () {}),
                    buildModernTileSection(context, "Help & Support", "",
                        Icons.support_agent, () {}),
                    buildModernTileSection(
                        context, "Settings", "", Icons.settings, () {}),
                  ]),
                  const SizedBox(height: 16),
                  _modernSectionContainer([
                    buildModernTileSection(context, "Log out", "",
                        Icons.exit_to_app, _handleLogout,
                        isLogout: true),
                  ]),
                  const SizedBox(height: 20),
                  Text(
                    "Host Panel v17.2.0",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoMessage(String message) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final bool isHost = user?.isHost ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          if (!(user?.isVerified ?? false))
            Container(
              width: 28,
              height: 28,
              decoration: isHost
                  ? BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF9C27B0)]),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
              child: InkWell(
                onTap: () {
                  showVerificationBottomSheet(context);
                },
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _modernSectionContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

Widget buildModernTileSection(BuildContext context, String title,
    String subtitle, IconData icon, VoidCallback onTap,
    {bool isLogout = false}) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final user = authProvider.user!.isHost;
  final bool isHost = user;
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isLogout ? Colors.red.shade50 : accentGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isLogout
              ? Colors.red
              : isHost
                  ? Color(0xFF2196F3)
                  : primaryGreen,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: isLogout ? Colors.red : darkGray,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            )
          : null,
      trailing: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
      onTap: onTap,
    ),
  );
}

void showVerificationBottomSheet(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  var registeredPhoneNumber = authProvider.user?.phoneNumber ?? "";
  // Remove "+91" if it exists
  if (registeredPhoneNumber.startsWith("+91")) {
    registeredPhoneNumber = registeredPhoneNumber.replaceFirst("+91", "");
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ProfileVerificationBottomSheet(
      registeredPhoneNumber: registeredPhoneNumber,
      onVerificationComplete: (isVerified) {},
    ),
  );
}

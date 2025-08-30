import 'package:flutter/material.dart';
import 'package:cmit/config/api.dart';
import 'package:cmit/config/routes.dart';
import 'package:cmit/core/local_storage.dart';
import 'package:cmit/core/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // User data
  Map<String, dynamic>? _userData;
  ImageProvider? _profileImage;

  // Loading state for logout
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from LocalStorage
  Future<void> _loadUserData() async {
    final userData = await LocalStorage.getUser();
    if (userData == null && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
      return;
    }
    if (userData != null && mounted) {
      setState(() {
        _userData = userData;
        // Load profile picture if available
        final profilePicture = userData['profile_picture']?.replaceAll('\\', '/');
        if (profilePicture != null && profilePicture.isNotEmpty) {
          _profileImage = NetworkImage('${ApiConfig.assetBaseUrl}/$profilePicture');
        }
      });
    }
  }

  // Handle logout
  Future<void> _logout() async {
    setState(() => _isLoading = true);
    try {
      final success = await AuthService.logout();
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully')),
          );
          print("🔹 Navigating to login screen...");
          Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
        } else {
          // Force local logout
          await LocalStorage.logout();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out locally due to server error.')),
          );
          print("🔹 Navigating to login screen...");
          Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
        }
      }
    } catch (e) {
      print("❌ ProfileScreen: Logout Error - $e");
      if (mounted) {
        setState(() => _isLoading = false);
        // Force local logout
        await LocalStorage.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out locally due to an error.')),
        );
        print("🔹 Navigating to login screen...");
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900]!,
          ),
        ),
      ),
      body: _userData == null
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture and Name
            _buildProfileHeader(context),
            const SizedBox(height: 24),

            // User Details
            _buildDetailsSection(context),
            const SizedBox(height: 24),

            // Logout Button
            _isLoading
                ? const CircularProgressIndicator(color: Colors.teal)
                : ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400]!,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                "LOGOUT",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: _profileImage,
          child: _profileImage == null
              ? const Icon(Icons.person, size: 80, color: Colors.black54)
              : null,
          onBackgroundImageError: _profileImage != null
              ? (error, stackTrace) {
            print("❌ ProfileScreen: Error loading profile image - $error");
            setState(() => _profileImage = null);
          }
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          _userData!['name'] ?? 'Unknown',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.teal[400]!,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          icon: Icons.email,
          label: 'Email',
          value: _userData!['email'] ?? 'N/A',
        ),
        _buildDivider(),
        _buildDetailRow(
          icon: Icons.person,
          label: 'Gender',
          value: _formatGender(_userData!['gender']),
        ),
        _buildDivider(),
        _buildDetailRow(
          icon: Icons.cake,
          label: 'Date of Birth',
          value: _userData!['date_of_birth'] ?? 'N/A',
        ),
        _buildDivider(),
        _buildDetailRow(
          icon: Icons.location_on,
          label: 'Address',
          value: _userData!['address'] ?? 'N/A',
          maxLines: 2,
        ),
        if (_userData!['strava_id'] != null) ...[
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.directions_run,
            label: 'Strava ID',
            value: _userData!['strava_id'].toString(),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.teal[400]!,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800]!,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: MediaQuery.of(context).size.width - 100, // Adjust for icon and padding
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600]!,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[300],
      thickness: 1,
      height: 16,
    );
  }

  String _formatGender(dynamic gender) {
    if (gender == null) return 'N/A';
    if (gender is int) {
      return gender == 0 ? 'Male' : gender == 1 ? 'Female' : 'Other';
    }
    return gender.toString();
  }
}
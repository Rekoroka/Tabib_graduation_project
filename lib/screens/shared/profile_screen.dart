import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool _resettingPassword = false;

  Future<void> _resetPassword() async {
    if (user?.email == null) {
      _showSnackBar("No email address found for this account", isError: true);
      return;
    }

    setState(() => _resettingPassword = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);

      if (mounted) {
        _showSnackBar(
          "Password reset email sent successfully!",
          isError: false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Failed to send reset email";

      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email address";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address";
      } else if (e.code == 'too-many-requests') {
        errorMessage = "Too many attempts. Please try again later";
      }

      if (mounted) {
        _showSnackBar("❌ $errorMessage", isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("An error occurred: $e", isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _resettingPassword = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_reset, color: Colors.blue),
              SizedBox(width: 8),
              Text("Reset Password"),
            ],
          ),
          content: const Text(
            "A password reset link will be sent to your email address. "
            "Do you want to continue?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetPassword();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Send Reset Link"),
            ),
          ],
        );
      },
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      _showSnackBar("Logout failed: $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _navigateToHome,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Profile Avatar with gradient
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.green.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.transparent,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // User Name
            Text(
              user?.displayName ?? 'User',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),

            const SizedBox(height: 8),

            // User Email
            Text(
              user?.email ?? 'No email',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 32),

            // Account Information Card
            _buildSectionCard(
              icon: Icons.info_outline_rounded,
              iconColor: Colors.blue,
              title: "Account Information",
              children: [
                _buildInfoItem(
                  Icons.person_outline_rounded,
                  'Name',
                  user?.displayName ?? 'Not set',
                ),
                const Divider(height: 20),
                _buildInfoItem(
                  Icons.email_outlined,
                  'Email',
                  user?.email ?? 'Not set',
                ),
                const Divider(height: 20),
                _buildInfoItem(
                  Icons.calendar_today_outlined,
                  'Member since',
                  user?.metadata.creationTime != null
                      ? DateFormat(
                          'MMM dd, yyyy',
                        ).format(user!.metadata.creationTime!)
                      : 'Unknown',
                ),
                const Divider(height: 20),
                _buildInfoItem(
                  Icons.verified_user_outlined,
                  'Email Verified',
                  user?.emailVerified == true ? 'Verified' : 'Not Verified',
                  valueColor: user?.emailVerified == true
                      ? Colors.green
                      : Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Security Section
            _buildSectionCard(
              icon: Icons.security_rounded,
              iconColor: Colors.orange,
              title: "Security",
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _resettingPassword
                        ? null
                        : _showResetPasswordDialog,
                    icon: _resettingPassword
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          )
                        : const Icon(Icons.lock_reset_rounded),
                    label: Text(
                      _resettingPassword ? "Sending..." : "Reset Password",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "You will receive a password reset link in your email",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Logout Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.red.shade600, Colors.orange.shade600],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        valueColor ??
                        Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

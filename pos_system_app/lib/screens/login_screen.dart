import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/app_colors.dart';
import 'pos_screen.dart';
import 'admin_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final Color primaryColor = AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SizedBox(
          width: 420,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 12,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_person, size: 60, color: primaryColor),
                  const SizedBox(height: 16),
                  const Text(
                    "Orion POS System",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// ================= ADMIN LOGIN =================
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.admin_panel_settings),
                      label: auth.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Admin Login with Google"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              FocusScope.of(context).unfocus();

                              bool success = await auth.loginWithGoogle();

                              if (!success) {
                                _showError(context, "Login failed. Try again.");
                                return;
                              }

                              if (!auth.isAdmin) {
                                _showError(context,
                                    "Access denied. Not an admin account.");
                                return;
                              }

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminScreen(),
                                ),
                              );
                            },
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ================= EMPLOYEE LOGIN =================
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Image.asset(
                        "assets/images/google.png",
                        height: 22,
                      ),
                      label: const Text("Employee Login with Google"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4285F4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              FocusScope.of(context).unfocus();

                              bool success = await auth.loginWithGoogle();

                              if (!success) {
                                _showError(context, "Login failed. Try again.");
                                return;
                              }

                              if (auth.isAdmin) {
                                _showError(context,
                                    "Admins must login using Admin button.");
                                return;
                              }

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PosScreen(),
                                ),
                              );
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

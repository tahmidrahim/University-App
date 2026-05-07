import 'package:flutter/material.dart';
import 'package:university/services/auth_service.dart';
import 'package:university/screens/main_nav_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';
  bool isLoading = false;

  final String validEmail = 'student@gmail.com';
  final String validPassword = '123456';

  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyLoggedIn();
  }

  Future<void> _checkIfAlreadyLoggedIn() async {
    if (!mounted) return;
    if (_auth.currentUser != null) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavScreen()),
    );
  }

  void login() {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    if (emailController.text == validEmail &&
        passwordController.text == validPassword) {
      _navigateToHome();
    } else {
      setState(() {
        errorMessage = 'Invalid email or password';
        isLoading = false;
      });
    }
  }

  void guestLogin() {
    _navigateToHome();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final user = await _auth.signInWithGoogle();

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (user != null) {
      _navigateToHome();
    } else {
      setState(() {
        errorMessage = 'Google Sign-In failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'UNIVERSITY PORTAL',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your academic journey starts here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: emailController,
                          label: 'Student Email',
                          icon: Icons.email_outlined,
                          type: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                        ),
                        if (errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),

                        if (isLoading)
                          const Center(child: CircularProgressIndicator())
                        else ...[
                          ElevatedButton(
                            onPressed: login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: Colors.grey.shade300),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: Colors.grey.shade300),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _signInWithGoogle,
                            icon: Image.network(
                              'https://www.google.com/images/branding/googleg/1x/googleg_standard_color_128dp.png',
                              height: 24,
                              width: 24,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.g_mobiledata, size: 24);
                              },
                            ),
                            label: const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: guestLogin,
                            child: Text(
                              "Continue as a Guest",
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Demo: student@gmail.com / 123456",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        filled: true,
        fillColor: Colors.grey.shade50,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
      ),
    );
  }
}

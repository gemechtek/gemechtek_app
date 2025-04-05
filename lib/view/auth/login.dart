// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:gemechtek_app/backend/providers/auth_provider.dart';
import 'package:gemechtek_app/navigation/main_navigation.dart';
import 'package:gemechtek_app/view/auth/signup.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _otpSent = false;
  final String _countryCode = '+91'; // Indian country code

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_otpSent ? 'Verify OTP' : 'Login'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isAuthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => const MainNavigationScreen()));
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                if (authProvider.error != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.red.shade100,
                    child: Text(
                      authProvider.error!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
                if (!_otpSent) ...[
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                      hintText: 'e.g., 9876543210',
                      prefixText: '+91 ',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    maxLength: 10, // Indian mobile numbers are 10 digits
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () => _sendOTP(context, authProvider),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blue,
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('LOGIN'),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: const Text('New user? Create an account'),
                  ),
                ] else ...[
                  const Text(
                    'Enter the OTP sent to your mobile',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Pinput(
                      controller: _otpController,
                      length: 6,
                      onCompleted: (pin) {
                        if (pin.length == 6) {
                          _verifyOTP(context, authProvider);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () => _verifyOTP(context, authProvider),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blue,
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('VERIFY & LOGIN'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _sendOTP(BuildContext context, AuthProvider authProvider) async {
    final phoneNumber = _phoneController.text.trim();

    // Validate inputs
    if (phoneNumber.isEmpty || phoneNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    // Prepend Indian country code
    final fullPhoneNumber = '$_countryCode$phoneNumber';
    final success = await authProvider.sendOTP(
      fullPhoneNumber,
      isLogin: true,
    );
    if (success) {
      setState(() {
        _otpSent = true;
      });
    }
  }

  Future<void> _verifyOTP(
      BuildContext context, AuthProvider authProvider) async {
    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    await authProvider.verifyOTPAndLogin(
      _otpController.text.trim(),
      '$_countryCode${_phoneController.text.trim()}', // Pass full number
    );
  }
}

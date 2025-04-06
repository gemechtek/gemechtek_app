// lib/screens/signup_screen.dart
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:spark_aquanix/backend/providers/auth_provider.dart';
import 'package:spark_aquanix/navigation/main_navigation.dart';
import 'package:spark_aquanix/widgets/error_widget.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _otpSent = false;
  final String _countryCode = '+91';

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isAuthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => const MainNavigationScreen()));
            });
          }
          if (authProvider.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text(authProvider.error!)),
              // );
              AnimatedSnackBar.material(
                authProvider.error!,
                type: AnimatedSnackBarType.error,
              ).show(context);

              authProvider.setErrorMessage(null);
            });
          }
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Image.asset(
                          "assets/images/signup.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: size.height * 0.1,
                        left: 24,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Get Started !..",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(color: Colors.white, fontSize: 30),
                            ),
                            SizedBox(
                              width: size.width * 0.72,
                              child: Text(
                                  "Register to explore and purchase high-quality aquacultural tools...",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                          color: Colors.white, fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _otpSent ? 'Verify OTP' : 'Sign Up',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 40),
                        // if (authProvider.error != null) ...[
                        //   ErrorDisplay(
                        //     errorMessage: authProvider.error!,
                        //     onRetry: () => setState(
                        //         () => authProvider.setErrorMessage(null)),
                        //   ),
                        //   SizedBox(height: 16),
                        // ],
                        if (!_otpSent) ...[
                          TextFormField(
                            autofillHints: const [AutofillHints.name],
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              if (value.length < 3) {
                                return 'Name must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            autofillHints: const [
                              AutofillHints.telephoneNumber
                            ],
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Mobile Number',
                              hintText: 'e.g., 9876543210',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your mobile number';
                              }
                              if (value.length < 10) {
                                return 'Mobile number must be 10 digits';
                              }
                              if (!RegExp(r'^\+?[0-9]{10,13}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid mobile number';
                              }

                              return null;
                            },
                          ),
                          // const SizedBox(height: 16),
                          // TextFormField(
                          //   controller: _addressController,
                          //   decoration: const InputDecoration(
                          //     labelText: 'Address (Optional)',
                          //     prefixIcon: Icon(Icons.home),
                          //   ),
                          //   maxLines: 2,
                          //   validator: (value) {
                          //     // Optional field, but if filled, should have minimum length
                          //     if (value != null &&
                          //         value.isNotEmpty &&
                          //         value.length < 5) {
                          //       return 'Address is too short';
                          //     }
                          //     return null;
                          //   },
                          // ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      _sendOTP(context, authProvider);
                                    }
                                  },
                            child: authProvider.isLoading
                                ? const CircularProgressIndicator()
                                : const Text('CREATE ACCOUNT'),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Already have an account? Login'),
                          ),
                        ] else ...[
                          const Text(
                            'Enter the OTP sent to your mobile',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          // Pinput already has built-in validation
                          Center(
                            child: Pinput(
                              controller: _otpController,
                              length: 6,
                              validator: (pin) {
                                if (pin == null || pin.isEmpty) {
                                  return 'Please enter the OTP';
                                }
                                if (pin.length != 6) {
                                  return 'OTP must be 6 digits';
                                }
                                if (!RegExp(r'^[0-9]{6}$').hasMatch(pin)) {
                                  return 'Invalid OTP format';
                                }
                                return null;
                              },
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
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      _verifyOTP(context, authProvider);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: Colors.blue,
                            ),
                            child: authProvider.isLoading
                                ? const CircularProgressIndicator()
                                : const Text('VERIFY & COMPLETE SIGNUP'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _sendOTP(BuildContext context, AuthProvider authProvider) async {
    final phoneNumber = _phoneController.text.trim();
    // final name = _nameController.text.trim();

    // We've already validated inputs using the form validator
    // But we'll keep these checks as an extra layer of safety

    // Prepend Indian country code
    final fullPhoneNumber =
        phoneNumber.contains("+91") ? phoneNumber : _countryCode + phoneNumber;

    final success = await authProvider.sendOTP(fullPhoneNumber, isLogin: false);

    if (success) {
      setState(() {
        _otpSent = true;
      });
    }
  }

  Future<void> _verifyOTP(
      BuildContext context, AuthProvider authProvider) async {
    // Form validation will handle OTP validation
    final phoneNumber = _phoneController.text.trim();
    final fullPhoneNumber =
        phoneNumber.contains("+91") ? phoneNumber : _countryCode + phoneNumber;
    final success = await authProvider.verifyOTPAndRegister(
      _otpController.text.trim(),
      _nameController.text.trim(),
      fullPhoneNumber,
    );

    if (success && _addressController.text.trim().isNotEmpty) {
      await authProvider.updateUserDetails(
        address: _addressController.text.trim(),
      );
    }
  }
}

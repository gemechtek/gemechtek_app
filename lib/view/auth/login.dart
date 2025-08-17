// // lib/screens/login_screen.dart
// import 'package:flutter/material.dart';
// import 'package:spark_aquanix/backend/providers/auth_provider.dart';
// import 'package:spark_aquanix/navigation/main_navigation.dart';
// import 'package:spark_aquanix/view/auth/signup.dart';
// import 'package:animated_snack_bar/animated_snack_bar.dart';
// import 'package:provider/provider.dart';
// // import 'package:pinput/pinput.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _otpController = TextEditingController();

//   bool _otpSent = false;
//   final String _countryCode = '+91'; // Indian country code

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _otpController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Text(_otpSent ? 'Verify OTP' : 'Login'),
//       // ),
//       body: Consumer<AuthProvider>(
//         builder: (context, authProvider, _) {
//           if (authProvider.error != null) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               // ScaffoldMessenger.of(context).showSnackBar(
//               //   SnackBar(content: Text(authProvider.error!)),
//               // );
//               AnimatedSnackBar.material(
//                 authProvider.error!,
//                 type: AnimatedSnackBarType.error,
//               ).show(context);

//               authProvider.setErrorMessage(null);
//             });
//           }
//           if (authProvider.isAuthenticated) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               Navigator.of(context).pushReplacement(MaterialPageRoute(
//                   builder: (_) => const MainNavigationScreen()));
//             });
//           }

//           return SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Stack(
//                   children: [
//                     SizedBox(
//                       width: double.infinity,
//                       child: Image.asset(
//                         "assets/images/login.png",
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     Positioned(
//                       top: size.height * 0.1,
//                       left: 24,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Welcome Back",
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .headlineLarge!
//                                 .copyWith(color: Colors.white, fontSize: 30),
//                           ),
//                           SizedBox(
//                             width: size.width * 0.72,
//                             child: Text(
//                                 "Log in to explore high-quality aquacultural tools and machines at the best prices.",
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodyLarge!
//                                     .copyWith(
//                                         color: Colors.white, fontSize: 16)),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       Text(
//                         _otpSent ? 'Verify OTP' : 'Login',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                             fontSize: 24, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 24),
//                       if (!_otpSent) ...[
//                         TextFormField(
//                           autofillHints: const [AutofillHints.telephoneNumber],
//                           controller: _phoneController,
//                           keyboardType: TextInputType.phone,
//                           decoration: const InputDecoration(
//                             labelText: 'Mobile Number',
//                             hintText: 'e.g., 9876543210',
//                             prefixIcon: Icon(Icons.phone),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your mobile number';
//                             }
//                             if (value.length < 10) {
//                               return 'Mobile number must be 10 digits';
//                             }
//                             if (!RegExp(r'^\+?[0-9]{10,13}$').hasMatch(value)) {
//                               return 'Please enter a valid mobile number';
//                             }

//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 24),
//                         ElevatedButton(
//                           onPressed: authProvider.isLoading
//                               ? null
//                               : () => _sendOTP(context, authProvider),
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 15),
//                             backgroundColor: Colors.blue,
//                           ),
//                           child: authProvider.isLoading
//                               ? const CircularProgressIndicator()
//                               : const Text('LOGIN'),
//                         ),
//                         const SizedBox(height: 20),
//                         TextButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (_) => const SignupScreen()),
//                             );
//                           },
//                           child: const Text('New user? Create an account'),
//                         ),
//                       ] else ...[
//                         const Text(
//                           'Enter the OTP sent to your mobile',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(fontSize: 18),
//                         ),
//                         const SizedBox(height: 16),
//                         Center(
//                           child: Pinput(
//                             controller: _otpController,
//                             length: 6,
//                             onCompleted: (pin) {
//                               if (pin.length == 6) {
//                                 _verifyOTP(context, authProvider);
//                               }
//                             },
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         ElevatedButton(
//                           onPressed: authProvider.isLoading
//                               ? null
//                               : () => _verifyOTP(context, authProvider),
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 15),
//                             backgroundColor: Colors.blue,
//                           ),
//                           child: authProvider.isLoading
//                               ? const CircularProgressIndicator()
//                               : const Text('VERIFY & LOGIN'),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 16),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Future<void> _sendOTP(BuildContext context, AuthProvider authProvider) async {
//     final phoneNumber = _phoneController.text.trim();

//     // Validate inputs
//     if (phoneNumber.isEmpty || phoneNumber.length < 10) {
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   const SnackBar(
//       //       content: Text('Please enter a valid 10-digit mobile number')),
//       // );
//       AnimatedSnackBar.material(
//         "Please enter a valid 10-digit mobile number",
//         type: AnimatedSnackBarType.info,
//       ).show(context);
//       return;
//     }

//     // Prepend Indian country code
//     // final fullPhoneNumber = '$_countryCode$phoneNumber';

//     final fullPhoneNumber =
//         phoneNumber.contains("+91") ? phoneNumber : _countryCode + phoneNumber;
//     final success = await authProvider.sendOTP(
//       fullPhoneNumber,
//       isLogin: true,
//     );
//     if (success) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           setState(() {
//             _otpSent = true;
//           });
//         }
//       });
//     }
//   }

//   Future<void> _verifyOTP(
//       BuildContext context, AuthProvider authProvider) async {
//     if (_otpController.text.trim().length != 6) {
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
//       // );
//       AnimatedSnackBar.material(
//         "Please enter a valid 6-digit OTP",
//         type: AnimatedSnackBarType.info,
//       ).show(context);
//       return;
//     }
//     final phoneNumber = _phoneController.text.trim();
//     final fullPhoneNumber =
//         phoneNumber.contains("+91") ? phoneNumber : _countryCode + phoneNumber;
//     bool islogin = await authProvider.verifyOTPAndLogin(
//       _otpController.text.trim(),
//       fullPhoneNumber,
//     );
//     if (islogin) {
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   const SnackBar(content: Text('Login successful')),
//       // );
//       AnimatedSnackBar.material(
//         "Login successful",
//         type: AnimatedSnackBarType.success,
//       ).show(context);
//     }
//   }
// }

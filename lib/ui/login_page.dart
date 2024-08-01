import 'dart:io';

import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final Telephony telephony = Telephony.instance;

  final TextEditingController _phoneContoller = TextEditingController();
  final TextEditingController _otpContoller = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();

  String extract6DigitOtp(String message) {
    // Implement your OTP extraction logic here
    // Example: Extracting a 6-digit OTP
    final otpRegex = RegExp(r'\b\d{6}\b');
    final match = otpRegex.firstMatch(message);
    return match?.group(0) ?? '';
  }

  String extract4DigitOtp(String message) {
    // Implement your OTP extraction logic here
    // Example: Extracting a 6-digit OTP
    final otpRegex = RegExp(r'\b\d{4}\b');
    final match = otpRegex.firstMatch(message);
    return match?.group(0) ?? '';
  }

  void listenToIncomingSMS(BuildContext context) {
    if (Platform.isAndroid) {
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          print(message.body);
          String otpCode = extract6DigitOtp(message.body ?? '');
          if (otpCode.isEmpty) {
            otpCode = extract4DigitOtp(message.body ?? '');
          }
          _otpContoller.text = otpCode;
          Future.delayed(const Duration(milliseconds: 100), () {
            handleSubmit(context);
          });
        },
        listenInBackground: false,
      );
    }
  }

// handle after otp is submitted
  void handleSubmit(BuildContext context) {
    print('here');
    if (_formKey1.currentState!.validate()) {
      AuthService.loginWithOtp(otp: _otpContoller.text).then((value) {
        if (value == "Success") {
          Navigator.pop(context);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        } else {
          print(value);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ));
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text("Enter you phone number to continue."),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _phoneContoller,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixText: "+91 ",
                          labelText: "Enter you phone number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        validator: (value) {
                          if (value!.length != 10) {
                            return "Invalid phone number";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            AuthService.sentOtp(
                              phone: _phoneContoller.text,
                              errorStep: () {
                                print('error');
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                    "Error in sending OTP",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ));
                              },
                              nextStep: () {
                                // start lisenting for otp
                                listenToIncomingSMS(context);
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("OTP Verification"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Enter 6 digit OTP"),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Form(
                                          key: _formKey1,
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            controller: _otpContoller,
                                            textInputAction:
                                                TextInputAction.done,
                                            decoration: InputDecoration(
                                              labelText: "Enter your OTP",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  32,
                                                ),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value!.length != 6) {
                                                return "Invalid OTP";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => handleSubmit(context),
                                        child: const Text("Submit"),
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            foregroundColor: Colors.black),
                        child: const Text("Send OTP"),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

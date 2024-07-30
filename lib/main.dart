import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:otp_auto/read_sms.dart';
import 'package:otp_auto/ui/login_page.dart';
import 'package:telephony/telephony.dart';
import 'firebase_options.dart';

//backgrounMessageHandler(SmsMessage message) async {}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Phone Auth Tutorial',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
          useMaterial3: true,
        ),
        home: LoginPage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

class ReadSms extends StatefulWidget {
  const ReadSms({super.key});

  @override
  State<ReadSms> createState() => _ReadSmsState();
}

class _ReadSmsState extends State<ReadSms> {
  final Telephony telephony = Telephony.instance;
  String textReceived = '';
  void startListening() {
    print('Listening to sms');
    telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          setState(() {
            textReceived = message.body!;
          });
        },
        listenInBackground: false);
  }

  @override
  void initState() {
    startListening();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read Incoming SMS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text('message Received: $textReceived')),
      ),
    );
  }
}

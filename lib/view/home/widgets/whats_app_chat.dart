import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppButton extends StatelessWidget {
  final String phoneNumber;
  final String message;

  const WhatsAppButton({
    super.key,
    this.phoneNumber = '916301712615',
    this.message = 'Hello! Reaching out from Spark Aquanix App.\n Regarding..',
  });

  Future<void> openWhatsAppChat() async {
    final whatsappUrl = Uri.parse(
      'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
    );
    // final webUrl = Uri.parse(
    //   'https://api.whatsapp.com/send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
    // );

    try {
      await launchUrl(whatsappUrl);
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: openWhatsAppChat,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          "assets/icon/whatsapp.png",
          height: 48,
          width: 48,
        ),
      ),
    );
  }
}

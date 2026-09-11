import 'package:url_launcher/url_launcher.dart';

class CommunicationService {
  /// Open native phone dialer with customer phone number
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final Uri url = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }

  /// Open WhatsApp with recipient phone number and optional text
  static Future<bool> openWhatsApp(String phoneNumber, {String message = ''}) async {
    // Format phone number for WhatsApp international standard
    String formattedPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '255${formattedPhone.substring(1)}';
    }

    final encodedMessage = Uri.encodeComponent(message);
    final Uri url = Uri.parse('https://wa.me/$formattedPhone?text=$encodedMessage');

    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }

  /// Open native SMS application composer
  static Future<bool> openSmsComposer(String phoneNumber, {String message = ''}) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final encodedMessage = Uri.encodeComponent(message);
    final Uri url = Uri.parse('sms:$cleanPhone?body=$encodedMessage');
    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }
}

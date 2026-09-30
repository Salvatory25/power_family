import 'package:flutter/foundation.dart';

class EmailServiceImpl {
  static Future<bool> sendWelcomeEmail(String toEmail, String fullName) async {
    debugPrint('SMTP Emails are not supported directly from Flutter Web browsers. Email sending bypassed.');
    return false;
  }

  static Future<bool> sendPasswordResetEmail(String toEmail, String resetLink) async {
    debugPrint('SMTP Emails are not supported directly from Flutter Web browsers. Email sending bypassed.');
    return false;
  }

  static Future<bool> sendNewPropertyBroadcast(List<String> bccEmails, String propertyTitle, String propertyType, String location, String price) async {
    debugPrint('SMTP Emails are not supported directly from Flutter Web browsers. Email sending bypassed.');
    return false;
  }
}

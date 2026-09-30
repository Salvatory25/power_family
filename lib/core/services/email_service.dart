import 'email_service_stub.dart'
    if (dart.library.io) 'email_service_io.dart'
    if (dart.library.html) 'email_service_web.dart';

class EmailService {
  static Future<bool> sendWelcomeEmail(String toEmail, String fullName) async {
    return await EmailServiceImpl.sendWelcomeEmail(toEmail, fullName);
  }

  static Future<bool> sendPasswordResetEmail(String toEmail, String resetLink) async {
    return await EmailServiceImpl.sendPasswordResetEmail(toEmail, resetLink);
  }

  static Future<bool> sendOTPEmail(String toEmail, String code, String firstName) async {
    return await EmailServiceImpl.sendOTPEmail(toEmail, code, firstName);
  }

  static Future<bool> sendNewPropertyBroadcast(List<String> bccEmails, String propertyTitle, String propertyType, String location, String price) async {
    return await EmailServiceImpl.sendNewPropertyBroadcast(bccEmails, propertyTitle, propertyType, location, price);
  }
}

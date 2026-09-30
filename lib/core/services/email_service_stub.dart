class EmailServiceImpl {
  static Future<bool> sendWelcomeEmail(String toEmail, String fullName) async => false;
  static Future<bool> sendPasswordResetEmail(String toEmail, String resetLink) async => false;
  static Future<bool> sendNewPropertyBroadcast(List<String> bccEmails, String propertyTitle, String propertyType, String location, String price) async => false;
}

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/foundation.dart';

class EmailServiceImpl {
  static final _smtpServer = SmtpServer(
    'mail.ephamarcysoftware.co.tz',
    username: 'suport@ephamarcysoftware.co.tz',
    password: 'Matundu@2050',
    port: 465,
    ssl: true,
  );

  /// Send Welcome Email for successful registration
  static Future<bool> sendWelcomeEmail(String toEmail, String fullName) async {
    final message = Message()
      ..from = const Address('suport@ephamarcysoftware.co.tz', 'Power Family Investment')
      ..recipients.add(toEmail)
      ..subject = 'Karibu Power Family Investment 🎉'
      ..html = '''
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #333;">
        <h2 style="color: #0A2342;">Welcome to Power Family Investment!</h2>
        <p>Habari <strong>$fullName</strong>,</p>
        <p>Hongera kwa kujiunga na Power Family Investment. Tumefurahi sana kuwa na wewe katika familia yetu.</p>
        <p>Kupitia mfumo wetu, utaweza:</p>
        <ul>
          <li>Kununua viwanja na nyumba kwa urahisi.</li>
          <li>Kupata taarifa za miradi mipya mapema.</li>
          <li>Kufuatilia malipo yako kwa njia rahisi zaidi.</li>
        </ul>
        <p>Ikiwa una swali lolote au unahitaji msaada, usisite kuwasiliana nasi.</p>
        <br>
        <p>Kila la kheri,<br><strong>Power Family Support Team</strong></p>
      </div>
      ''';

    try {
      final sendReport = await send(message, _smtpServer);
      debugPrint('Welcome Email Sent: $sendReport');
      return true;
    } catch (e) {
      debugPrint('Error sending welcome email: $e');
      return false;
    }
  }

  /// Send Forgot Password Email
  static Future<bool> sendPasswordResetEmail(String toEmail, String resetLink) async {
    final message = Message()
      ..from = const Address('suport@ephamarcysoftware.co.tz', 'Power Family Security')
      ..recipients.add(toEmail)
      ..subject = 'Reset Your Power Family Password'
      ..html = '''
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #333;">
        <h2 style="color: #E63946;">Password Reset Request</h2>
        <p>Habari,</p>
        <p>Tumepokea ombi la kubadilisha nenosiri (password) ya akaunti yako ya Power Family Investment.</p>
        <p>Ili kubadilisha nenosiri lako, tafadhali bonyeza kitufe hapo chini:</p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="$resetLink" style="background-color: #0A2342; color: #ffffff; padding: 12px 24px; text-decoration: none; border-radius: 8px; font-weight: bold;">Reset Password</a>
        </div>
        <p>Ikiwa haujaomba kubadilisha nenosiri, tafadhali puuzia barua pepe hii na akaunti yako itakuwa salama.</p>
        <br>
        <p>Kila la kheri,<br><strong>Power Family Security Team</strong></p>
      </div>
      ''';

    try {
      final sendReport = await send(message, _smtpServer);
      debugPrint('Password Reset Email Sent: $sendReport');
      return true;
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      return false;
    }
  }

  /// Send 6-Digit OTP Email
  static Future<bool> sendOTPEmail(String toEmail, String code, String firstName) async {
    final message = Message()
      ..from = const Address('suport@ephamarcysoftware.co.tz', 'Power Family Security')
      ..recipients.add(toEmail)
      ..subject = 'Your Power Family Reset Code: $code'
      ..html = '''
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #333;">
        <h2 style="color: #0A2342;">Password Reset Code</h2>
        <p>Habari $firstName,</p>
        <p>Tumepokea ombi la kubadilisha nenosiri lako. Ingiza tarakimu 6 zifuatazo kwenye application ili kukamilisha:</p>
        <div style="text-align: center; margin: 30px 0;">
          <h1 style="background-color: #F8F9FA; padding: 16px; border-radius: 8px; font-size: 38px; letter-spacing: 8px; color: #1D4ED8; display: inline-block;">$code</h1>
        </div>
        <p>Ikiwa haujaomba kubadilisha nenosiri, tafadhali puuzia barua pepe hii.</p>
        <br>
        <p>Kila la kheri,<br><strong>Power Family Security Team</strong></p>
      </div>
      ''';

    try {
      final sendReport = await send(message, _smtpServer);
      debugPrint('OTP Email Sent: $sendReport');
      return true;
    } catch (e) {
      debugPrint('Error sending OTP email: $e');
      return false;
    }
  }

  /// Broadcast New Property to a list of emails
  static Future<bool> sendNewPropertyBroadcast(List<String> bccEmails, String propertyTitle, String propertyType, String location, String price) async {
    if (bccEmails.isEmpty) return false;
    
    final message = Message()
      ..from = const Address('suport@ephamarcysoftware.co.tz', 'Power Family Investment')
      ..bccRecipients.addAll(bccEmails)
      ..subject = 'Fursa Mpya: $propertyTitle ipo Sokoni! 🏡'
      ..html = '''
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #333;">
        <h2 style="color: #0077B6;">Fursa Mpya Ya Uwekezaji!</h2>
        <p>Habari mteja wetu mpendwa,</p>
        <p>Kuna fursa mpya ya uwekezaji imeingia sokoni na tumeona ni vyema ukawa wa kwanza kujua.</p>
        <div style="background-color: #F8F9FA; padding: 16px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #0077B6;">
          <h3 style="margin-top: 0; color: #0A2342;">$propertyTitle</h3>
          <p><strong>Aina:</strong> $propertyType</p>
          <p><strong>Eneo:</strong> $location</p>
          <p><strong>Bei:</strong> TZS $price</p>
        </div>
        <p>Ingia kwenye application yako ya Power Family sasa hivi ili kuona picha, ramani, na maelezo kamili ya fursa hii kabla haijachukuliwa!</p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="https://powerfamily.co.tz/app" style="background-color: #0A2342; color: #ffffff; padding: 12px 24px; text-decoration: none; border-radius: 8px; font-weight: bold;">Fungua Application</a>
        </div>
        <p>Karibu tukuhudumie,<br><strong>Power Family Investment Team</strong></p>
      </div>
      ''';

    try {
      final sendReport = await send(message, _smtpServer);
      debugPrint('Property Broadcast Email Sent: $sendReport');
      return true;
    } catch (e) {
      debugPrint('Error sending broadcast email: $e');
      return false;
    }
  }
}

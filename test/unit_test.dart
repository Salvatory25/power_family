import 'package:flutter_test/flutter_test.dart';
import 'package:power_family/core/constants/app_constants.dart';
import 'package:power_family/core/utils/formatters.dart';


void main() {
  group('POWER FAMILY Core Logic & Formatter Tests', () {
    test('Formats Tanzanian Shillings (TZS) correctly', () {
      expect(Formatters.formatCurrency(50000000), equals('TZS 50,000,000'));
      expect(Formatters.formatCurrency(185000000.50), equals('TZS 185,000,001'));
      expect(Formatters.formatCurrency(0), equals('TZS 0'));
    });

    test('Validates Tanzanian Phone Numbers correctly', () {
      expect(Formatters.validatePhone('+255712345678'), isNull);
      expect(Formatters.validatePhone('0712345678'), isNull);
      expect(Formatters.validatePhone('123'), isNotNull);
      expect(Formatters.validatePhone(''), isNotNull);
    });

    test('Role Labels resolution', () {
      expect(AppConstants.getRoleLabel(AppConstants.roleSuperAdmin), equals('Super Admin'));
      expect(AppConstants.getRoleLabel(AppConstants.roleBranchManager), equals('Branch Manager'));
      expect(AppConstants.getRoleLabel(AppConstants.roleSalesAgent), equals('Sales Agent'));
      expect(AppConstants.getRoleLabel(AppConstants.roleSurveyor), equals('Surveyor / Land Officer'));
    });

  });
}

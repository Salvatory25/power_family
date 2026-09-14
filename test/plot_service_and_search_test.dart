import 'package:flutter_test/flutter_test.dart';
import 'package:power_family/core/services/plot_import_service.dart';
import 'package:power_family/core/services/global_search_service.dart';

void main() {
  group('Plot Import & Validation Tests', () {
    test('CSV parsing validates required fields and generates Plot IDs', () {
      const csvData = '''plot_number,block_name,area_sqm,list_price,land_use
0001,Block A,500,15000000,RESIDENTIAL
0002,Block A,600,18000000,COMMERCIAL''';

      final result = PlotImportService.parseAndValidateCsv(
        csvData,
        defaultProjectId: 'PRJ-KIB-001',
        defaultBranchId: 'BRANCH-KIB',
        branchCode: 'PFI-KIB',
        existingPlotIds: [],
      );

      expect(result.isValid, isTrue);
      expect(result.validPlots.length, equals(2));
      expect(result.validPlots[0].plotId, equals('PFI-KIB-000001'));
      expect(result.validPlots[1].plotId, equals('PFI-KIB-000002'));
    });

    test('CSV parsing detects duplicate Plot IDs', () {
      const csvData = '''plot_number,block_name,area_sqm,list_price,land_use
0001,Block A,500,15000000,RESIDENTIAL''';

      final result = PlotImportService.parseAndValidateCsv(
        csvData,
        defaultProjectId: 'PRJ-KIB-001',
        defaultBranchId: 'BRANCH-KIB',
        branchCode: 'PFI-KIB',
        existingPlotIds: ['PFI-KIB-000001'],
      );

      expect(result.validPlots.length, equals(0));
      expect(result.duplicateCount, equals(1));
    });
  });

  group('Global Search Engine Tests', () {
    test('Cross-entity search returns matching customer and plot records', () {
      final results = GlobalSearchService.searchAll(
        'PFI-KIB-000001',
        customers: [
          {'id': 'PFI-CUST-000001', 'fullName': 'Juma Hamisi', 'phone': '0712345678'}
        ],
        plots: [
          {
            'id': 'plot-1',
            'plotId': 'PFI-KIB-000001',
            'plotNumber': '000001',
            'blockName': 'Block A',
            'availabilityStatus': 'AVAILABLE',
            'region': 'Pwani'
          }
        ],
        invoices: [],
        receipts: [],
        titles: [],
        halmashauriApps: [],
      );

      expect(results.length, equals(1));
      expect(results[0].category, equals('PLOT'));
      expect(results[0].title, contains('PFI-KIB-000001'));
    });
  });
}

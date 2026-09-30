import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';

import '../../models/property_model.dart';
import '../../models/user_model.dart';
import '../../models/branch_model.dart';
import '../../models/sale_model.dart';
import '../../core/utils/formatters.dart';

class PdfReportGenerator {
  static Future<Uint8List> generateReport({
    required List<PropertyModel> properties,
    required List<UserModel> users,
    required List<BranchModel> branches,
    required List<SaleModel> sales,
  }) async {
    final pdf = pw.Document();

    final totalSalesVal = properties
        .where((p) => p.status == 'SOLD')
        .fold<double>(0, (sum, p) => sum + p.price);
    final actualPayments = sales.fold<double>(0, (sum, s) => sum + s.amount);

    final nyumbaCount = properties.where((p) => p.type.toUpperCase() == 'NYUMBA').length;
    final kiwanjaCount = properties.where((p) => p.type.toUpperCase() == 'KIWANJA').length;
    final gariCount = properties.where((p) => p.type.toUpperCase() == 'GARI').length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            
            // Finance Overview
            _buildSectionTitle('Finance & Analytics'),
            _buildFinanceCard(totalSalesVal, actualPayments),
            pw.SizedBox(height: 20),

            // Portfolio
            _buildSectionTitle('Portfolio Distribution'),
            _buildPortfolioBreakdown(nyumbaCount, kiwanjaCount, gariCount),
            pw.SizedBox(height: 20),

            // Branch Performance
            _buildSectionTitle('Branch Performance'),
            _buildBranchPerformanceTable(branches, properties),
            pw.SizedBox(height: 20),

            // Staff & Customers
            _buildSectionTitle('Staff & Users'),
            _buildUsersSummary(users),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue900,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Power Family Analytics Hub',
                style: pw.TextStyle(color: PdfColors.white, fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Generated on: ${Formatters.formatDateTime(DateTime.now())}',
                style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12, top: 12),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
      ),
    );
  }

  static pw.Widget _buildFinanceCard(double totalSalesVal, double actualPayments) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Total Realized Revenue (Sold)', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
          pw.SizedBox(height: 4),
          pw.Text(Formatters.formatCurrency(totalSalesVal), style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
          pw.SizedBox(height: 8),
          pw.Text('Actual Payments Received: ${Formatters.formatCurrency(actualPayments)}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  static pw.Widget _buildPortfolioBreakdown(int nyumba, int kiwanja, int gari) {
    return pw.Row(
      children: [
        _buildMiniCard('Nyumba', nyumba.toString(), PdfColors.blue),
        pw.SizedBox(width: 8),
        _buildMiniCard('Kiwanja', kiwanja.toString(), PdfColors.orange),
        pw.SizedBox(width: 8),
        _buildMiniCard('Gari', gari.toString(), PdfColors.amber),
      ],
    );
  }

  static pw.Widget _buildMiniCard(String title, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(value, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: color)),
            pw.SizedBox(height: 4),
            pw.Text(title, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildBranchPerformanceTable(List<BranchModel> branches, List<PropertyModel> properties) {
    final headers = ['Branch Name', 'Properties Sold', 'Revenue Generated'];
    final data = branches.map((b) {
      final bProps = properties.where((p) => p.branchId == b.id && p.status == 'SOLD').toList();
      final rev = bProps.fold<double>(0, (sum, p) => sum + p.price);
      return [
        b.name,
        bProps.length.toString(),
        Formatters.formatCurrency(rev),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildUsersSummary(List<UserModel> users) {
    final superAdmins = users.where((u) => u.role == 'super_admin').length;
    final branchManagers = users.where((u) => u.role == 'branch_manager').length;
    final staff = users.length - superAdmins - branchManagers;

    return pw.Row(
      children: [
        _buildMiniCard('Super Admins', superAdmins.toString(), PdfColors.red),
        pw.SizedBox(width: 8),
        _buildMiniCard('Branch Managers', branchManagers.toString(), PdfColors.purple),
        pw.SizedBox(width: 8),
        _buildMiniCard('Sales/Field Staff', staff.toString(), PdfColors.green),
      ],
    );
  }
}

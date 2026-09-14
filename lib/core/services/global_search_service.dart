import 'package:flutter/foundation.dart';

class GlobalSearchResultItem {
  final String category; // CUSTOMER, PLOT, PROJECT, BOOKING, SALE, INVOICE, RECEIPT, TITLE_DEED, HALMASHAURI
  final String id;
  final String title;
  final String subtitle;
  final String routePath;
  final Map<String, dynamic> rawData;

  GlobalSearchResultItem({
    required this.category,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.routePath,
    required this.rawData,
  });
}

class GlobalSearchService {
  /// Performs cross-entity search across customer names/phones, plot IDs, invoice numbers,
  /// receipt codes, control numbers, title numbers, and Halmashauri application refs.
  static List<GlobalSearchResultItem> searchAll(String query, {
    required List<Map<String, dynamic>> customers,
    required List<Map<String, dynamic>> plots,
    required List<Map<String, dynamic>> invoices,
    required List<Map<String, dynamic>> receipts,
    required List<Map<String, dynamic>> titles,
    required List<Map<String, dynamic>> halmashauriApps,
  }) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final List<GlobalSearchResultItem> results = [];

    // Search Customers
    for (var c in customers) {
      final name = (c['fullName'] ?? '').toString().toLowerCase();
      final phone = (c['phone'] ?? '').toString().toLowerCase();
      final custId = (c['id'] ?? '').toString().toLowerCase();

      if (name.contains(q) || phone.contains(q) || custId.contains(q)) {
        results.add(
          GlobalSearchResultItem(
            category: 'CUSTOMER',
            id: c['id'] ?? '',
            title: c['fullName'] ?? 'Customer',
            subtitle: 'Phone: ${c['phone']} • ID: ${c['id']}',
            routePath: '/customers/${c['id']}',
            rawData: c,
          ),
        );
      }
    }

    // Search Plots
    for (var p in plots) {
      final plotId = (p['plotId'] ?? p['plot_id'] ?? '').toString().toLowerCase();
      final plotNum = (p['plotNumber'] ?? '').toString().toLowerCase();
      final block = (p['blockName'] ?? '').toString().toLowerCase();

      if (plotId.contains(q) || plotNum.contains(q) || block.contains(q)) {
        results.add(
          GlobalSearchResultItem(
            category: 'PLOT',
            id: p['id'] ?? plotId,
            title: 'Plot ${(p['plotId'] ?? p['plot_id'] ?? '').toString().toUpperCase()} ($block)',
            subtitle: 'Status: ${p['availabilityStatus']} • ${p['region']}',
            routePath: '/plots/${p['id']}',
            rawData: p,
          ),
        );
      }
    }

    // Search Invoices & Control Numbers
    for (var inv in invoices) {
      final invNum = (inv['invoiceNumber'] ?? '').toString().toLowerCase();
      final ctrlNo = (inv['controlNumber'] ?? '').toString().toLowerCase();

      if (invNum.contains(q) || ctrlNo.contains(q)) {
        results.add(
          GlobalSearchResultItem(
            category: 'INVOICE',
            id: inv['id'] ?? invNum,
            title: 'Invoice $invNum',
            subtitle: 'Amount: TZS ${inv['totalAmount']} • Status: ${inv['status']}',
            routePath: '/invoices/${inv['id']}',
            rawData: inv,
          ),
        );
      }
    }

    // Search Receipts
    for (var rec in receipts) {
      final recNum = (rec['receiptNumber'] ?? '').toString().toLowerCase();
      if (recNum.contains(q)) {
        results.add(
          GlobalSearchResultItem(
            category: 'RECEIPT',
            id: rec['id'] ?? recNum,
            title: 'Receipt $recNum',
            subtitle: 'Paid: TZS ${rec['amountPaid']}',
            routePath: '/receipts/${rec['id']}',
            rawData: rec,
          ),
        );
      }
    }

    // Search Title Deeds (Hati Miliki)
    for (var title in titles) {
      final titleNum = (title['titleNumber'] ?? '').toString().toLowerCase();
      if (titleNum.contains(q)) {
        results.add(
          GlobalSearchResultItem(
            category: 'TITLE_DEED',
            id: title['id'] ?? titleNum,
            title: 'Hati Miliki $titleNum',
            subtitle: 'Stage: ${title['workflowStage']}',
            routePath: '/titles/${title['id']}',
            rawData: title,
          ),
        );
      }
    }

    return results;
  }
}

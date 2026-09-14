import 'package:flutter/material.dart';
import '../../models/customer_model.dart';

class Customer360Screen extends StatefulWidget {
  final CustomerModel customer;

  const Customer360Screen({super.key, required this.customer});

  @override
  State<Customer360Screen> createState() => _Customer360ScreenState();
}

class _Customer360ScreenState extends State<Customer360Screen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'Profile',
    'Purchases & Plots',
    'Bookings',
    'Invoices & Payments',
    'Site Visits',
    'Documents',
    'Follow-ups',
    'Timeline',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.customer;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('ID: ${c.id} • ${c.phone}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(c),
          _buildPurchasesTab(),
          _buildBookingsTab(),
          _buildFinanceTab(),
          _buildVisitsTab(),
          _buildDocumentsTab(),
          _buildFollowUpsTab(),
          _buildTimelineTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab(CustomerModel c) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customer Profile 360', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Divider(),
                _infoRow('Full Name:', c.fullName),
                _infoRow('Phone:', c.phone),
                _infoRow('Email:', c.email),
                _infoRow('Address:', c.address),
                _infoRow('Lead Status:', c.status),
                _infoRow('Branch ID:', c.branchId),
                _infoRow('Budget:', 'TZS ${c.budget.toStringAsFixed(0)}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchasesTab() => const Center(child: Text('Active Plots Purchased & Installment Schedules'));
  Widget _buildBookingsTab() => const Center(child: Text('Active & Historical Plot Bookings'));
  Widget _buildFinanceTab() => const Center(child: Text('Invoices, Payment Receipts & Statement of Account'));
  Widget _buildVisitsTab() => const Center(child: Text('Site Visits & Field Inspection History'));
  Widget _buildDocumentsTab() => const Center(child: Text('Signed Contracts, National IDs & Title Copies'));
  Widget _buildFollowUpsTab() => const Center(child: Text('Scheduled Staff Follow-ups & Reminders'));
  Widget _buildTimelineTab() => const Center(child: Text('360 Audit & Event Log'));

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

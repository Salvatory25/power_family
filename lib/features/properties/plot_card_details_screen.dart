import 'package:flutter/material.dart';
import '../../models/plot_model.dart';
import '../../core/constants/app_constants.dart';

class PlotCardDetailsScreen extends StatefulWidget {
  final PlotModel plot;

  const PlotCardDetailsScreen({super.key, required this.plot});

  @override
  State<PlotCardDetailsScreen> createState() => _PlotCardDetailsScreenState();
}

class _PlotCardDetailsScreenState extends State<PlotCardDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'Overview',
    'Map',
    'Customer',
    'Sale',
    'Payments',
    'Documents',
    'Survey',
    'BITCON',
    'Halmashauri',
    'Title Deed',
    'Timeline',
    'Communication',
    'Notes',
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

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return Colors.green;
      case 'BOOKED':
      case 'RESERVED':
        return Colors.orange;
      case 'SOLD':
      case 'FULLY_PAID':
        return Colors.blue;
      case 'TITLE_READY':
      case 'HANDED_OVER':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final plot = widget.plot;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plot.plotId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('${plot.blockName} • ${plot.district}, ${plot.region}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(plot.availabilityStatus).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getStatusColor(plot.availabilityStatus)),
            ),
            child: Text(
              plot.availabilityStatus,
              style: TextStyle(
                color: _getStatusColor(plot.availabilityStatus),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(plot),
          _buildMapTab(plot),
          _buildCustomerTab(plot),
          _buildSaleTab(plot),
          _buildPaymentsTab(plot),
          _buildDocumentsTab(plot),
          _buildSurveyTab(plot),
          _buildBitconTab(plot),
          _buildHalmashauriTab(plot),
          _buildTitleDeedTab(plot),
          _buildTimelineTab(plot),
          _buildCommunicationTab(plot),
          _buildNotesTab(plot),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(PlotModel plot) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Plot Specifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Divider(),
                _infoRow('Plot ID:', plot.plotId),
                _infoRow('Plot Number:', plot.plotNumber),
                _infoRow('Block:', plot.blockName),
                _infoRow('Land Use:', plot.landUse),
                _infoRow('Area:', '${plot.areaSqm} sqm'),
                _infoRow('List Price:', 'TZS ${plot.listPrice.toStringAsFixed(0)}'),
                _infoRow('Selling Price:', 'TZS ${plot.sellingPrice.toStringAsFixed(0)}'),
                _infoRow('Deposit Required:', 'TZS ${plot.requiredDeposit.toStringAsFixed(0)}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapTab(PlotModel plot) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, size: 64, color: Colors.indigo),
          const SizedBox(height: 16),
          Text('GIS Coordinates: Lat ${plot.gpsLatitude ?? 'N/A'}, Lng ${plot.gpsLongitude ?? 'N/A'}'),
          const SizedBox(height: 8),
          Text('Polygon Boundaries: ${plot.boundaryCoordinates.length} points captured'),
        ],
      ),
    );
  }

  Widget _buildCustomerTab(PlotModel plot) {
    return Center(
      child: Text(plot.currentCustomerId != null
          ? 'Customer Assigned: ${plot.currentCustomerId}'
          : 'No Customer Assigned Yet'),
    );
  }

  Widget _buildSaleTab(PlotModel plot) {
    return Center(
      child: Text(plot.currentSaleId != null ? 'Sale ID: ${plot.currentSaleId}' : 'Plot is Available for Sale'),
    );
  }

  Widget _buildPaymentsTab(PlotModel plot) {
    return const Center(child: Text('Financial Ledger & Receipts'));
  }

  Widget _buildDocumentsTab(PlotModel plot) {
    return const Center(child: Text('Plot Documents & Cadastral Maps'));
  }

  Widget _buildSurveyTab(PlotModel plot) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.architecture, size: 48, color: Colors.blue),
          const SizedBox(height: 12),
          Text('Survey Status: ${plot.surveyStatus}'),
        ],
      ),
    );
  }

  Widget _buildBitconTab(PlotModel plot) {
    return Center(
      child: Text('BITCON Status: ${plot.bitconStatus}'),
    );
  }

  Widget _buildHalmashauriTab(PlotModel plot) {
    return Center(
      child: Text('Halmashauri Status: ${plot.halmashauriStatus}'),
    );
  }

  Widget _buildTitleDeedTab(PlotModel plot) {
    return Center(
      child: Text('Title Deed (Hati Miliki): ${plot.titleStatus}'),
    );
  }

  Widget _buildTimelineTab(PlotModel plot) {
    return const Center(child: Text('Audit & Event Timeline'));
  }

  Widget _buildCommunicationTab(PlotModel plot) {
    return const Center(child: Text('Customer Messages & Call Log'));
  }

  Widget _buildNotesTab(PlotModel plot) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(plot.notes ?? 'No internal notes added yet.'),
    );
  }

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

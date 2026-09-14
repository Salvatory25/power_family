import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class LandProcessingDashboardScreen extends StatefulWidget {
  const LandProcessingDashboardScreen({super.key});

  @override
  State<LandProcessingDashboardScreen> createState() => _LandProcessingDashboardScreenState();
}

class _LandProcessingDashboardScreenState extends State<LandProcessingDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Land Processing Hub (Upimaji, BITCON & Hati)'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.verified), text: 'BITCON'),
            Tab(icon: Icon(Icons.account_balance), text: 'Halmashauri'),
            Tab(icon: Icon(Icons.workspace_premium), text: 'Title Deeds (Hati)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBitconList(),
          _buildHalmashauriList(),
          _buildTitleDeedsList(),
        ],
      ),
    );
  }

  Widget _buildBitconList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProcessingCard(
          id: 'BIT-2026-0001',
          plotId: 'PFI-KIB-000012',
          customerName: 'Juma Hamisi Ally',
          stage: 'IN_PROGRESS',
          date: '2026-09-10',
          badgeColor: Colors.blue,
        ),
        _buildProcessingCard(
          id: 'BIT-2026-0002',
          plotId: 'PFI-DSM-000045',
          customerName: 'Amina Saidi Hassan',
          stage: 'SUBMITTED',
          date: '2026-09-12',
          badgeColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildHalmashauriList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProcessingCard(
          id: 'HAL-2026-0089',
          plotId: 'PFI-KIB-000008',
          customerName: 'Kassim Omari Mfaume',
          stage: 'PROCESSING',
          subtext: 'Halmashauri ya Wilaya ya Kibaha - Idara ya Ardhi',
          date: '2026-09-08',
          badgeColor: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildTitleDeedsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProcessingCard(
          id: 'HT-2026-0004',
          plotId: 'PFI-ARU-000003',
          customerName: 'Emmanuel Joseph Massawe',
          stage: 'TITLE_READY',
          subtext: 'Wizara ya Ardhi • Ready for Customer Collection',
          date: '2026-09-14',
          badgeColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildProcessingCard({
    required String id,
    required String plotId,
    required String customerName,
    required String stage,
    String? subtext,
    required String date,
    required Color badgeColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$id ($plotId)', style: const TextStyle(fontWeight: FontWeight.bold)),
            Chip(
              label: Text(stage, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              backgroundColor: badgeColor,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Customer: $customerName'),
            if (subtext != null) Text(subtext, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Submission Date: $date', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../repositories/seed_data.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class LandProcessingHubScreen extends ConsumerStatefulWidget {
  const LandProcessingHubScreen({super.key});

  @override
  ConsumerState<LandProcessingHubScreen> createState() => _LandProcessingHubScreenState();
}

class _LandProcessingHubScreenState extends ConsumerState<LandProcessingHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Land Processing & Title Hub', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.satellite_alt_rounded), text: 'GNSS / RTK Survey'),
            Tab(icon: Icon(Icons.token_rounded), text: 'BITCON Workflow'),
            Tab(icon: Icon(Icons.account_balance_rounded), text: 'Halmashauri Files'),
            Tab(icon: Icon(Icons.card_membership_rounded), text: 'Title Deeds (Hati)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. GNSS / RTK Survey Monitor
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Live Survey Receiver Hardware Telemetry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  children: const [
                    StatCard(title: 'Positioning Mode', value: 'RTK FIX', icon: Icons.gps_fixed_rounded, color: Color(0xFF10B981)),
                    StatCard(title: 'Satellites Locked', value: '18 Satellites', icon: Icons.satellite_rounded, color: AppColors.accent),
                    StatCard(title: 'Horizontal Precision (HDOP)', value: '0.82 m', icon: Icons.straighten_rounded, color: Colors.blue),
                    StatCard(title: 'Calculated Accuracy', value: '±0.015 m', icon: Icons.precision_manufacturing_rounded, color: Colors.purple),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.sensors_rounded, color: Color(0xFF10B981)),
                            SizedBox(width: 8),
                            Text('Active NMEA Data Stream', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        const Divider(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)),
                          child: const Text(
                            '\$GNGGA,094110.00,-6.8167,S,39.2833,E,4,18,0.82,14.2,M,0.0,M,,*6A\n\$GNRMC,094110.00,A,-6.8167,S,39.2833,E,0.02,,140926,,,D*7F',
                            style: TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. BITCON Workflow
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (context, idx) {
              final bitconId = 'BIT-2026-00000${idx + 1}';
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.background,
                    child: Icon(Icons.build_circle_outlined, color: AppColors.primary),
                  ),
                  title: Text(bitconId, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Plot PFI-KIB-00000${idx + 1} • Application Ref: BIT-REF-99$idx'),
                  trailing: const StatusBadge(status: 'IN_PROGRESS'),
                ),
              );
            },
          ),

          // 3. Halmashauri Applications
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (context, idx) {
              final halNo = 'HAL-2026-00000${idx + 1}';
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(halNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const StatusBadge(status: 'PROCESSING'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Department: Idara ya Ardhi na Mipango Miji'),
                      Text('File No: HAL/KIB/2026/0${idx + 1} • Officer: Land Inspector'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.event_outlined, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('Next Follow-up Date: 20 Sep 2026', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 4. Title Deeds (Hati Miliki) 8-Stage Tracker
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (context, idx) {
              final titleNo = 'HT-2026-00000${idx + 1}';
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(titleNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const StatusBadge(status: 'TITLE_READY'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Issuing Authority: Wizara ya Ardhi (Ministry of Lands)'),
                      Text('Plot: PFI-KIB-00000${idx + 1} • Customer: Juma Hamisi'),
                      const SizedBox(height: 12),
                      const Text('8-Stage Workflow Stage: TITLE READY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0.75,
                        backgroundColor: AppColors.border,
                        color: Colors.blue,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

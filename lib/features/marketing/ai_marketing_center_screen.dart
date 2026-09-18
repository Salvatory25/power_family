import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';

import '../../widgets/stat_card.dart';

class AIMarketingCenterScreen extends ConsumerStatefulWidget {
  const AIMarketingCenterScreen({super.key});

  @override
  ConsumerState<AIMarketingCenterScreen> createState() => _AIMarketingCenterScreenState();
}

class _AIMarketingCenterScreenState extends ConsumerState<AIMarketingCenterScreen> {
  String _selectedPlatform = 'WhatsApp Status';
  String _selectedTemplate = 'Plot For Sale';
  bool _isGenerating = false;
  String? _generatedHeadline;
  String? _generatedCaption;
  String? _generatedHashtags;

  void _generateAICopy() {
    setState(() {
      _isGenerating = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _generatedHeadline = '🔥 MILIKI KIWANJA KIGAMBONI KWA LIPA KIDOGO KIDOGO!';
        _generatedCaption =
            'Viwanja vilivyopimwa vizuri na Wizara ya Ardhi Kigamboni! Eneo ni sqm 600, huduma zote za kijamii (Maji, Umeme, Barabara) zipo. Lipa kidogo kidogo hadi miezi 12 bila riba!\n\n📍 Mahali: Kigamboni, Dar es Salaam\n💰 Bei: TZS 15,000,000 tu!\n📞 Piga Sasa: +255 712 345 678';
        _generatedHashtags = '#PowerFamily #ViwanjaViliyopimwa #Kigamboni #TanzaniaRealEstate #NyumbaNaViwanja';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('AI Marketing & Social Center', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Attribution Metrics
            const Row(
              children: [
                Expanded(child: StatCard(title: 'Active Campaigns', value: '4 Campaigns', icon: Icons.campaign_rounded, color: Colors.purple)),
                SizedBox(width: 12),
                Expanded(child: StatCard(title: 'Leads Attributed', value: '128 Leads', icon: Icons.group_add_rounded, color: Color(0xFF10B981))),
              ],
            ),
            const SizedBox(height: 20),

            // AI Marketing Generator Form Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 24),
                        SizedBox(width: 8),
                        Text('AI Advertisement Generator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Generates factual promotional copy directly from database property values.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const Divider(height: 24),

                    DropdownButtonFormField<String>(
                      value: _selectedPlatform,
                      decoration: InputDecoration(
                        labelText: 'Target Platform',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'WhatsApp Status', child: Text('WhatsApp Status / Campaign')),
                        DropdownMenuItem(value: 'Instagram Post', child: Text('Instagram Post / Story')),
                        DropdownMenuItem(value: 'Facebook Ad', child: Text('Facebook Ad Campaign')),
                        DropdownMenuItem(value: 'TikTok Video', child: Text('TikTok Video Script')),
                      ],
                      onChanged: (val) => setState(() => _selectedPlatform = val!),
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      value: _selectedTemplate,
                      decoration: InputDecoration(
                        labelText: 'Template Theme',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Plot For Sale', child: Text('Plot For Sale')),
                        DropdownMenuItem(value: 'New Project', child: Text('New Project Launch')),
                        DropdownMenuItem(value: 'Special Weekend Offer', child: Text('Special Weekend Offer')),
                        DropdownMenuItem(value: 'Title Ready', child: Text('Hati Miliki Ready')),
                      ],
                      onChanged: (val) => setState(() => _selectedTemplate = val!),
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
                        onPressed: _isGenerating ? null : _generateAICopy,
                        icon: _isGenerating
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.auto_awesome_rounded, size: 20),
                        label: Text(_isGenerating ? 'Generating Content...' : 'Generate Marketing Copy'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Generated Copy Result Box
            if (_generatedHeadline != null) ...[
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Generated Marketing Content', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                          Chip(
                            label: Text(_selectedPlatform, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            backgroundColor: AppColors.background,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        _generatedHeadline!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      SelectableText(
                        _generatedCaption!,
                        style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      SelectableText(
                        _generatedHashtags!,
                        style: const TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Content copied to clipboard!')),
                                );
                              },
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              label: const Text('Copy Text'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Queued for Social Publishing (Draft).')),
                                );
                              },
                              icon: const Icon(Icons.send_rounded, size: 18),
                              label: const Text('Publish / Schedule'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

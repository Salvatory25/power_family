import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/property_model.dart';
import '../dashboard/dashboard_providers.dart';
import '../../widgets/status_badge.dart';

class DigitalPlotMapScreen extends ConsumerStatefulWidget {
  const DigitalPlotMapScreen({super.key});

  @override
  ConsumerState<DigitalPlotMapScreen> createState() => _DigitalPlotMapScreenState();
}

class _DigitalPlotMapScreenState extends ConsumerState<DigitalPlotMapScreen> {
  String _selectedProject = 'All Projects';
  String _selectedStatusFilter = 'ALL';
  PropertyModel? _selectedPlot;

  @override
  Widget build(BuildContext context) {
    final allProperties = ref.watch(propertiesProvider).value ?? [];
    final plots = allProperties.where((p) {
      final matchesProject = _selectedProject == 'All Projects' || p.location.contains(_selectedProject);
      final matchesStatus = _selectedStatusFilter == 'ALL' || p.status == _selectedStatusFilter;
      return matchesProject && matchesStatus;
    }).toList();


    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Interactive Plot Map (GIS)', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload GIS Map',
            onPressed: () {
              setState(() {
                _selectedPlot = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('GIS Plot Map refreshed from database.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedProject,
                    decoration: InputDecoration(
                      labelText: 'Project Area',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'All Projects', child: Text('All Projects')),
                      DropdownMenuItem(value: 'Kigamboni', child: Text('Kigamboni Commercial')),
                      DropdownMenuItem(value: 'Kibaha', child: Text('Kibaha Industrial Estate')),
                      DropdownMenuItem(value: 'Arusha', child: Text('Arusha Safari View')),
                    ],
                    onChanged: (val) => setState(() => _selectedProject = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatusFilter,
                    decoration: InputDecoration(
                      labelText: 'Status Filter',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All Statuses')),
                      DropdownMenuItem(value: AppConstants.propertyAvailable, child: Text('Available')),
                      DropdownMenuItem(value: AppConstants.propertyReserved, child: Text('Reserved')),
                      DropdownMenuItem(value: AppConstants.propertySold, child: Text('Sold')),
                    ],
                    onChanged: (val) => setState(() => _selectedStatusFilter = val!),
                  ),
                ),
              ],
            ),
          ),

          // Map Legend
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.background,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _legendItem('Available', const Color(0xFF10B981)),
                  const SizedBox(width: 16),
                  _legendItem('Reserved', const Color(0xFFF59E0B)),
                  const SizedBox(width: 16),
                  _legendItem('Sold', const Color(0xFFEF4444)),
                  const SizedBox(width: 16),
                  _legendItem('Title Ready', Colors.blue),
                ],
              ),
            ),
          ),

          // Interactive Grid / Plot Canvas View
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 500
                          ? 4
                          : (MediaQuery.of(context).size.width > 360 ? 3 : 2),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: plots.length,
                    itemBuilder: (context, index) {
                      final plot = plots[index];
                      final isSelected = _selectedPlot?.id == plot.id;
                      Color statusColor;
                      if (plot.status == AppConstants.propertyAvailable) {
                        statusColor = const Color(0xFF10B981);
                      } else if (plot.status == AppConstants.propertyReserved) {
                        statusColor = const Color(0xFFF59E0B);
                      } else {
                        statusColor = const Color(0xFFEF4444);
                      }

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPlot = plot;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(isSelected ? 0.25 : 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : statusColor,
                              width: isSelected ? 2.5 : 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.landscape_rounded, color: statusColor, size: 26),
                              const SizedBox(height: 4),
                              Text(
                                'Plot ${plot.plotNumber ?? plot.propertyCode}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text(
                                plot.size ?? 'N/A',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Selected Plot Bottom Card
                if (_selectedPlot != null)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedPlot!.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      Text(
                                        'Code: ${_selectedPlot!.propertyCode} • Size: ${_selectedPlot!.size}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(status: _selectedPlot!.status),
                              ],
                            ),
                            const Divider(height: 16),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Text(
                                  Formatters.formatCurrency(_selectedPlot!.price),
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        minimumSize: Size.zero,
                                      ),
                                      onPressed: () {
                                        context.push('/plot-details', extra: _selectedPlot);
                                      },
                                      child: const Text('View Plot', style: TextStyle(fontSize: 12)),
                                    ),
                                    const SizedBox(width: 6),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accent,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        minimumSize: Size.zero,
                                      ),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Plot ${_selectedPlot!.propertyCode} booking initiated.')),
                                        );
                                      },
                                      child: const Text('Book Plot', style: TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

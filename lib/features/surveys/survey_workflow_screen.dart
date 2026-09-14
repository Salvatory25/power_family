import 'package:flutter/material.dart';

class SurveyPointItem {
  final String pointId;
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;
  final String positioningMode;
  final DateTime timestamp;

  SurveyPointItem({
    required this.pointId,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    required this.positioningMode,
    required this.timestamp,
  });
}

class SurveyWorkflowScreen extends StatefulWidget {
  final String plotId;
  final String projectName;

  const SurveyWorkflowScreen({
    super.key,
    required this.plotId,
    required this.projectName,
  });

  @override
  State<SurveyWorkflowScreen> createState() => _SurveyWorkflowScreenState();
}

class _SurveyWorkflowScreenState extends State<SurveyWorkflowScreen> {
  final List<SurveyPointItem> _capturedPoints = [];
  bool _isRtkConnected = false;
  String _rtkMode = 'SMARTPHONE_GPS'; // SMARTPHONE_GPS, DGPS, RTK_FLOAT, RTK_FIX
  int _satellitesCount = 14;
  double _hdop = 0.9;
  double _vdop = 1.1;

  void _captureCurrentPoint() {
    setState(() {
      final pointNum = _capturedPoints.length + 1;
      _capturedPoints.add(
        SurveyPointItem(
          pointId: 'P$pointNum',
          latitude: -6.7924 + (pointNum * 0.0001),
          longitude: 38.9750 + (pointNum * 0.0001),
          altitude: 120.5,
          accuracy: _rtkMode == 'RTK_FIX' ? 0.015 : (_rtkMode == 'RTK_FLOAT' ? 0.25 : 3.5),
          positioningMode: _rtkMode,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Survey (Upimaji) - ${widget.plotId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generate Survey PDF',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generating official Survey PDF Report...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Device & Positioning Telemetry Header
          Container(
            color: Colors.indigo.shade900,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Positioning: $_rtkMode',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Chip(
                      label: Text(_isRtkConnected ? 'RTK GNSS CONNECTED' : 'SMARTPHONE GPS'),
                      backgroundColor: _isRtkConnected ? Colors.green : Colors.amber,
                      labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Satellites: $_satellitesCount', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('HDOP: $_hdop', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('VDOP: $_vdop', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // Captured Points List
          Expanded(
            child: _capturedPoints.isEmpty
                ? const Center(
                    child: Text('No boundary points captured yet. Tap "Capture Boundary Point" below.'),
                  )
                : ListView.builder(
                    itemCount: _capturedPoints.length,
                    itemBuilder: (context, index) {
                      final pt = _capturedPoints[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(pt.pointId),
                        ),
                        title: Text('Lat: ${pt.latitude.toStringAsFixed(6)}, Lng: ${pt.longitude.toStringAsFixed(6)}'),
                        subtitle: Text('Accuracy: ${pt.accuracy}m • Mode: ${pt.positioningMode}'),
                        trailing: Text('${pt.timestamp.hour}:${pt.timestamp.minute.toString().padLeft(2, '0')}'),
                      );
                    },
                  ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_location_alt),
                    label: const Text('Capture Point'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _captureCurrentPoint,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isRtkConnected = !_isRtkConnected;
                      _rtkMode = _isRtkConnected ? 'RTK_FIX' : 'SMARTPHONE_GPS';
                    });
                  },
                  child: Text(_isRtkConnected ? 'Disconnect RTK' : 'Connect RTK'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

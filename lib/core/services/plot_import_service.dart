import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/plot_model.dart';

class PlotImportValidationResult {
  final bool isValid;
  final List<PlotModel> validPlots;
  final List<String> errors;
  final List<String> warnings;
  final int totalRowsParsed;
  final int duplicateCount;

  PlotImportValidationResult({
    required this.isValid,
    required this.validPlots,
    required this.errors,
    required this.warnings,
    required this.totalRowsParsed,
    required this.duplicateCount,
  });
}

class PlotImportService {
  /// Parses raw CSV text, validates required fields, checks for duplicate Plot IDs,
  /// and returns a validation summary report before committing to DB.
  static PlotImportValidationResult parseAndValidateCsv(
    String rawCsvContent, {
    required String defaultProjectId,
    required String defaultBranchId,
    required String branchCode, // e.g. PFI-KIB
    required List<String> existingPlotIds,
  }) {
    final List<PlotModel> validPlots = [];
    final List<String> errors = [];
    final List<String> warnings = [];
    final Set<String> seenPlotIds = Set<String>.from(existingPlotIds);
    int totalRows = 0;
    int duplicateCount = 0;

    final lines = LineSplitter.split(rawCsvContent).toList();
    if (lines.isEmpty) {
      return PlotImportValidationResult(
        isValid: false,
        validPlots: [],
        errors: ['CSV file is empty.'],
        warnings: [],
        totalRowsParsed: 0,
        duplicateCount: 0,
      );
    }

    // Row 0 is assumed header: plot_number, block_name, area_sqm, list_price, land_use, region, district
    final header = lines.first.toLowerCase().split(',');
    
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      totalRows++;
      final fields = line.split(',');
      if (fields.length < 4) {
        errors.add('Row ${i + 1}: Insufficient columns. Minimum required: plot_number, block_name, area_sqm, list_price');
        continue;
      }

      final plotNumber = fields[0].trim();
      final blockName = fields[1].trim();
      final double? areaSqm = double.tryParse(fields[2].trim());
      final double? listPrice = double.tryParse(fields[3].trim());
      final landUse = fields.length > 4 ? fields[4].trim().toUpperCase() : 'RESIDENTIAL';
      final region = fields.length > 5 ? fields[5].trim() : 'Pwani';
      final district = fields.length > 6 ? fields[6].trim() : 'Kibaha';

      if (plotNumber.isEmpty) {
        errors.add('Row ${i + 1}: Missing plot number.');
        continue;
      }
      if (blockName.isEmpty) {
        errors.add('Row ${i + 1}: Missing block name.');
        continue;
      }
      if (areaSqm == null || areaSqm <= 0) {
        errors.add('Row ${i + 1}: Invalid or missing area_sqm.');
        continue;
      }
      if (listPrice == null || listPrice <= 0) {
        errors.add('Row ${i + 1}: Invalid or missing list_price.');
        continue;
      }

      final generatedPlotId = '$branchCode-${plotNumber.padLeft(6, '0')}';

      if (seenPlotIds.contains(generatedPlotId)) {
        duplicateCount++;
        warnings.add('Row ${i + 1}: Plot ID $generatedPlotId already exists in database or batch. Skipped.');
        continue;
      }

      seenPlotIds.add(generatedPlotId);

      final plot = PlotModel(
        id: generatedPlotId,
        plotId: generatedPlotId,
        plotNumber: plotNumber,
        blockName: blockName,
        projectId: defaultProjectId,
        branchId: defaultBranchId,
        region: region,
        district: district,
        areaSqm: areaSqm,
        landUse: landUse,
        listPrice: listPrice,
        sellingPrice: listPrice,
        availabilityStatus: 'AVAILABLE',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      validPlots.add(plot);
    }

    return PlotImportValidationResult(
      isValid: errors.isEmpty,
      validPlots: validPlots,
      errors: errors,
      warnings: warnings,
      totalRowsParsed: totalRows,
      duplicateCount: duplicateCount,
    );
  }
}

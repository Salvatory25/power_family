import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/property_model.dart';

class PropertyRepository {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _resolveBranchUuid(
    SupabaseClient supabase,
    String? requestedId,
  ) async {
    try {
      if (requestedId != null &&
          requestedId.length == 36 &&
          requestedId.contains('-')) {
        return requestedId;
      }
      final res = await supabase.from('branches').select('id').limit(1);
      if (res != null && (res as List).isNotEmpty) {
        return res.first['id'].toString();
      }
      final inserted = await supabase
          .from('branches')
          .insert({
            'name': 'Dar es Salaam HQ',
            'code': 'PF-DAR',
            'region': 'Dar es Salaam',
            'district': 'Kinondoni',
            'phone': '+255 712 000 111',
            'email': 'dar@powerfamily.co.tz',
          })
          .select()
          .single();
      return inserted['id'].toString();
    } catch (e) {
      print('Error resolving branch UUID: $e');
      return null;
    }
  }

  Future<String?> _resolveProjectUuid(
    SupabaseClient supabase,
    String branchUuid,
  ) async {
    try {
      final res = await supabase.from('projects').select('id').limit(1);
      if (res != null && (res as List).isNotEmpty) {
        return res.first['id'].toString();
      }
      final inserted = await supabase
          .from('projects')
          .insert({
            'branch_id': branchUuid,
            'project_code': 'PRJ-PF-001',
            'name': 'Power Family Main Project',
            'region': 'Dar es Salaam',
            'district': 'Kigamboni',
            'total_area_sqm': 50000.0,
          })
          .select()
          .single();
      return inserted['id'].toString();
    } catch (e) {
      print('Error resolving project UUID: $e');
      return null;
    }
  }

  Future<List<PropertyModel>> getProperties({
    String? branchId,
    String? type,
    String? status,
    String? searchQuery,
  }) async {
    List<PropertyModel> list = [];
    try {
      final supabase = _supabase;
      if (supabase != null) {
        var query = supabase.from('plots').select();
        if (branchId != null && branchId.isNotEmpty && branchId.length == 36) {
          query = query.eq('branch_id', branchId);
        }
        if (status != null && status.isNotEmpty && status != 'all') {
          query = query.eq('availability_status', status.toUpperCase());
        }
        final response = await query;
        if (response != null && (response as List).isNotEmpty) {
          final List<PropertyModel> mappedList = [];
          for (final rawItem in (response as List)) {
            final map = rawItem as Map<String, dynamic>;
            final meta = map['metadata'] as Map<String, dynamic>? ?? {};

            mappedList.add(
              PropertyModel(
                id: (map['id'] ?? map['plot_id'] ?? '').toString(),
                propertyCode: (map['plot_id'] ?? 'PFI-KW-001').toString(),
                title: meta['title']?.toString() ?? 'Plot ${map['plot_number'] ?? '001'} (${map['block_name'] ?? 'Block A'})',
                type: (map['plot_type'] ?? 'KIWANJA').toString(),
                description: (map['location_description'] ?? 'Surveyed plot in ${map['district'] ?? 'Dar es Salaam'}').toString(),
                price: (map['list_price'] as num?)?.toDouble() ?? 15000000.0,
                location: '${map['district'] ?? 'District'}, ${map['region'] ?? 'Region'}',
                region: (map['region'] ?? 'Dar es Salaam').toString(),
                district: (map['district'] ?? 'Kigamboni').toString(),
                ward: map['ward']?.toString(),
                street: map['village_street']?.toString(),
                size: meta['size']?.toString() ?? '${map['area_sqm'] ?? 500} SQM',
                plotNumber: map['plot_number']?.toString(),
                blockNumber: map['block_name']?.toString(),
                landUse: map['land_use']?.toString(),
                surveyStatus: meta['surveyStatus']?.toString() ?? map['survey_status']?.toString(),
                registrationStatus: meta['registrationStatus']?.toString() ?? map['title_status']?.toString(),
                bedrooms: meta['bedrooms'] is int ? meta['bedrooms'] as int : int.tryParse(meta['bedrooms']?.toString() ?? ''),
                bathrooms: meta['bathrooms'] is int ? meta['bathrooms'] as int : int.tryParse(meta['bathrooms']?.toString() ?? ''),
                vehicleMake: meta['vehicleMake']?.toString(),
                vehicleModel: meta['vehicleModel']?.toString(),
                vehicleYear: meta['vehicleYear'] is int ? meta['vehicleYear'] as int : int.tryParse(meta['vehicleYear']?.toString() ?? ''),
                vehicleRegistration: meta['vehicleRegistration']?.toString(),
                images:
                    (map['images'] as List?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    const [
                      'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&q=80',
                    ],
                documents:
                    (map['documents'] as List?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    const ['Title_Deed_Kigamboni.pdf'],
                status: (map['availability_status'] ?? 'AVAILABLE').toString(),
                branchId: (map['branch_id'] ?? '').toString(),
                assignedAgentId: map['assigned_sales_agent_id']?.toString(),
                createdBy: (map['created_by'] ?? 'system').toString(),
                createdAt: map['created_at'] != null
                    ? DateTime.tryParse(map['created_at'].toString()) ??
                          DateTime.now()
                    : DateTime.now(),
                updatedAt: map['updated_at'] != null
                    ? DateTime.tryParse(map['updated_at'].toString()) ??
                          DateTime.now()
                    : DateTime.now(),
              ),
            );
          }
          list = mappedList;
        }
      }
    } catch (e) {
      print('Error loading properties: $e');
    }


    if (type != null && type.isNotEmpty && type != 'all') {
      list = list
          .where((p) => p.type.toLowerCase() == type.toLowerCase())
          .toList();
    }
    if (status != null && status.isNotEmpty && status != 'all') {
      list = list
          .where((p) => p.status.toLowerCase() == status.toLowerCase())
          .toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.propertyCode.toLowerCase().contains(q) ||
            p.location.toLowerCase().contains(q) ||
            p.region.toLowerCase().contains(q) ||
            p.district.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  Future<PropertyModel> createProperty(PropertyModel property) async {
    PropertyModel created = property;
    try {
      final supabase = _supabase;
      if (supabase != null) {
        final branchUuid = await _resolveBranchUuid(
          supabase,
          property.branchId,
        );
        if (branchUuid == null)
          throw Exception('Branch UUID resolution failed');
        final projectUuid = await _resolveProjectUuid(supabase, branchUuid);
        if (projectUuid == null)
          throw Exception('Project UUID resolution failed');

        final inserted = await supabase
            .from('plots')
            .insert({
              'plot_id': property.propertyCode,
              'plot_number': property.plotNumber ?? '001',
              'block_name': property.blockNumber ?? 'Block A',
              'project_id': projectUuid,
              'branch_id': branchUuid,
              'region': property.region.isNotEmpty
                  ? property.region
                  : 'Dar es Salaam',
              'district': property.district.isNotEmpty
                  ? property.district
                  : 'Kigamboni',
              'ward': property.ward,
              'village_street': property.street,
              'location_description': property.description,
              'area_sqm':
                  double.tryParse(
                    property.size?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '',
                  ) ??
                  500.0,
              'list_price': property.price,
              'availability_status': property.status.toUpperCase(),
              'images': property.images,
              'plot_type': property.type,
              'metadata': {
                'title': property.title,
                'bedrooms': property.bedrooms,
                'bathrooms': property.bathrooms,
                'vehicleMake': property.vehicleMake,
                'vehicleModel': property.vehicleModel,
                'vehicleYear': property.vehicleYear,
                'vehicleRegistration': property.vehicleRegistration,
                'size': property.size,
                'surveyStatus': property.surveyStatus,
                'registrationStatus': property.registrationStatus,
              },
            })
            .select()
            .single();

        created = PropertyModel(
          id: inserted['id'].toString(),
          propertyCode: (inserted['plot_id'] ?? property.propertyCode)
              .toString(),
          title: property.title,
          type: property.type,
          description: property.description,
          price: property.price,
          location: property.location,
          region: property.region,
          district: property.district,
          ward: property.ward,
          street: property.street,
          size: property.size,
          plotNumber: property.plotNumber,
          blockNumber: property.blockNumber,
          landUse: property.landUse,
          surveyStatus: property.surveyStatus,
          registrationStatus: property.registrationStatus,
          images: property.images.isNotEmpty
              ? property.images
              : const [
                  'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&q=80',
                ],
          documents: property.documents,
          status: property.status,
          branchId: branchUuid,
          assignedAgentId: property.assignedAgentId,
          createdBy: property.createdBy,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error creating property in Supabase: $e');
    }


    return created;
  }

  Future<void> updatePropertyStatus(String propertyId, String newStatus) async {
    try {
      final supabase = _supabase;
      if (supabase != null) {
        await supabase
            .from('plots')
            .update({
              'availability_status': newStatus.toUpperCase(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', propertyId);
      }
    } catch (e) {
      print('Error updating property status: $e');
    }
  }

  Future<void> updateProperty(PropertyModel property) async {
    try {
      final supabase = _supabase;
      if (supabase != null) {
        final updateData = {
          'plot_id': property.propertyCode,
          'plot_number': property.plotNumber ?? '001',
          'block_name': property.blockNumber ?? 'Block A',
          'region': property.region.isNotEmpty ? property.region : 'Dar es Salaam',
          'district': property.district.isNotEmpty ? property.district : 'Kigamboni',
          'ward': property.ward,
          'village_street': property.street,
          'location_description': property.description,
          'area_sqm': double.tryParse(property.size?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '') ?? 500.0,
          'list_price': property.price,
          'availability_status': property.status.toUpperCase(),
          'updated_at': DateTime.now().toIso8601String(),
          'plot_type': property.type,
          'metadata': {
            'title': property.title,
            'bedrooms': property.bedrooms,
            'bathrooms': property.bathrooms,
            'vehicleMake': property.vehicleMake,
            'vehicleModel': property.vehicleModel,
            'vehicleYear': property.vehicleYear,
            'vehicleRegistration': property.vehicleRegistration,
            'size': property.size,
            'surveyStatus': property.surveyStatus,
            'registrationStatus': property.registrationStatus,
          },
        };

        if (property.images.isNotEmpty) {
          updateData['images'] = property.images;
        }

        await supabase.from('plots').update(updateData).eq('id', property.id);
      }
    } catch (e) {
      print('Error updating property: $e');
    }
  }

  Future<void> deleteProperty(String propertyId) async {
    try {
      final supabase = _supabase;
      if (supabase != null) {
        await supabase.from('plots').delete().eq('id', propertyId);
      }
    } catch (e) {
      print('Error deleting property: $e');
    }
  }
  Future<String?> uploadPropertyImage(Uint8List bytes, String fileName) async {
    try {
      final supabase = _supabase;
      if (supabase != null) {
        final path = 'properties/$fileName';
        await supabase.storage.from('property_images').uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
            );
        return supabase.storage.from('property_images').getPublicUrl(path);
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
    return null;
  }
}

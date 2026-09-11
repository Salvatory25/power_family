import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale_model.dart';
import '../core/constants/app_constants.dart';
import 'seed_data.dart';
import 'property_repository.dart';

class SalesRepository {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  final PropertyRepository _propertyRepo = PropertyRepository();

  Future<List<SaleModel>> getSales({String? branchId, String? agentId}) async {
    List<SaleModel> list = [];
    try {
      final store = _firestore;
      if (store != null) {
        Query query = store.collection('sales');
        if (branchId != null && branchId.isNotEmpty) {
          query = query.where('branchId', isEqualTo: branchId);
        }
        if (agentId != null && agentId.isNotEmpty) {
          query = query.where('agentId', isEqualTo: agentId);
        }
        final snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          list = snapshot.docs
              .map((doc) => SaleModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();
        }
      }
    } catch (_) {}

    if (list.isEmpty) {
      list = List.from(SeedData.sales);
      if (branchId != null && branchId.isNotEmpty) {
        list = list.where((s) => s.branchId == branchId).toList();
      }
      if (agentId != null && agentId.isNotEmpty) {
        list = list.where((s) => s.agentId == agentId).toList();
      }
    }
    return list;
  }

  Future<SaleModel> recordSale(SaleModel sale) async {
    try {
      final store = _firestore;
      if (store != null) {
        final docRef = await store.collection('sales').add(sale.toMap());
        final newSale = SaleModel.fromMap(sale.toMap(), docRef.id);
        SeedData.sales.add(newSale);

        if (sale.saleStatus == AppConstants.saleCompleted) {
          await _propertyRepo.updatePropertyStatus(sale.propertyId, AppConstants.propertySold);
        } else if (sale.paymentStatus == AppConstants.paymentPartial) {
          await _propertyRepo.updatePropertyStatus(sale.propertyId, AppConstants.propertyReserved);
        }
        return newSale;
      }
    } catch (_) {}

    final newId = 'sale_${DateTime.now().millisecondsSinceEpoch}';
    final newSale = SaleModel.fromMap(sale.toMap(), newId);
    SeedData.sales.add(newSale);

    if (sale.saleStatus == AppConstants.saleCompleted) {
      await _propertyRepo.updatePropertyStatus(sale.propertyId, AppConstants.propertySold);
    }
    return newSale;
  }
}

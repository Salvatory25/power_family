import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/survey_task_model.dart';
import 'seed_data.dart';

class SurveyRepository {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  Future<List<SurveyTaskModel>> getSurveyTasks({String? branchId, String? surveyorId}) async {
    List<SurveyTaskModel> list = [];
    try {
      final store = _firestore;
      if (store != null) {
        Query query = store.collection('survey_tasks');
        if (branchId != null && branchId.isNotEmpty) {
          query = query.where('branchId', isEqualTo: branchId);
        }
        if (surveyorId != null && surveyorId.isNotEmpty) {
          query = query.where('surveyorId', isEqualTo: surveyorId);
        }
        final snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          list = snapshot.docs
              .map((doc) => SurveyTaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();
        }
      }
    } catch (_) {}

    if (list.isEmpty) {
      list = List.from(SeedData.surveyTasks);
      if (branchId != null && branchId.isNotEmpty) {
        list = list.where((t) => t.branchId == branchId).toList();
      }
      if (surveyorId != null && surveyorId.isNotEmpty) {
        list = list.where((t) => t.surveyorId == surveyorId).toList();
      }
    }
    return list;
  }

  Future<SurveyTaskModel> createSurveyTask(SurveyTaskModel task) async {
    try {
      final store = _firestore;
      if (store != null) {
        final docRef = await store.collection('survey_tasks').add(task.toMap());
        final newTask = SurveyTaskModel.fromMap(task.toMap(), docRef.id);
        SeedData.surveyTasks.add(newTask);
        return newTask;
      }
    } catch (_) {}

    final newId = 'survey_${DateTime.now().millisecondsSinceEpoch}';
    final newTask = SurveyTaskModel.fromMap(task.toMap(), newId);
    SeedData.surveyTasks.add(newTask);
    return newTask;
  }

  Future<void> updateSurveyTaskStatus(String taskId, String newStatus, String notes) async {
    try {
      final store = _firestore;
      if (store != null) {
        await store.collection('survey_tasks').doc(taskId).update({
          'status': newStatus,
          'notes': notes,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
    final idx = SeedData.surveyTasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final old = SeedData.surveyTasks[idx];
      SeedData.surveyTasks[idx] = SurveyTaskModel(
        id: old.id,
        propertyId: old.propertyId,
        surveyorId: old.surveyorId,
        branchId: old.branchId,
        status: newStatus,
        deadline: old.deadline,
        notes: notes,
        documents: old.documents,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }
}

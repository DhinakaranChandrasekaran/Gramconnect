import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/complaint_model.dart';

class OfflineService {
  static const String _complaintsBoxName = 'offline_complaints';
  static const String _imagesBoxName = 'offline_images';

  Future<Box> _getComplaintsBox() async {
    if (!Hive.isBoxOpen(_complaintsBoxName)) {
      return await Hive.openBox(_complaintsBoxName);
    }
    return Hive.box(_complaintsBoxName);
  }

  Future<Box> _getImagesBox() async {
    if (!Hive.isBoxOpen(_imagesBoxName)) {
      return await Hive.openBox(_imagesBoxName);
    }
    return Hive.box(_imagesBoxName);
  }

  Future<void> saveComplaint(ComplaintModel complaint, String? imageBase64) async {
    try {
      final complaintsBox = await _getComplaintsBox();
      final imagesBox = await _getImagesBox();

      // Save complaint data
      await complaintsBox.put(complaint.id, jsonEncode(complaint.toJson()));

      // Save image data if available
      if (imageBase64 != null && imageBase64.isNotEmpty) {
        await imagesBox.put('${complaint.id}_image', imageBase64);
      }
    } catch (e) {
      throw Exception('Failed to save complaint offline: ${e.toString()}');
    }
  }

  Future<List<ComplaintModel>> getOfflineComplaints() async {
    try {
      final complaintsBox = await _getComplaintsBox();
      final List<ComplaintModel> complaints = [];

      for (final key in complaintsBox.keys) {
        final complaintJson = complaintsBox.get(key);
        if (complaintJson != null) {
          final complaintData = jsonDecode(complaintJson);
          complaints.add(ComplaintModel.fromJson(complaintData));
        }
      }

      // Sort by creation date (newest first)
      complaints.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return complaints;
    } catch (e) {
      throw Exception('Failed to load offline complaints: ${e.toString()}');
    }
  }

  Future<String?> getOfflineImage(String complaintId) async {
    try {
      final imagesBox = await _getImagesBox();
      return imagesBox.get('${complaintId}_image');
    } catch (e) {
      return null;
    }
  }

  Future<void> removeComplaint(String complaintId) async {
    try {
      final complaintsBox = await _getComplaintsBox();
      final imagesBox = await _getImagesBox();

      // Remove complaint data
      await complaintsBox.delete(complaintId);

      // Remove associated image
      await imagesBox.delete('${complaintId}_image');
    } catch (e) {
      throw Exception('Failed to remove offline complaint: ${e.toString()}');
    }
  }

  Future<void> clearAllOfflineData() async {
    try {
      final complaintsBox = await _getComplaintsBox();
      final imagesBox = await _getImagesBox();

      await complaintsBox.clear();
      await imagesBox.clear();
    } catch (e) {
      throw Exception('Failed to clear offline data: ${e.toString()}');
    }
  }

  Future<int> getOfflineComplaintCount() async {
    try {
      final complaintsBox = await _getComplaintsBox();
      return complaintsBox.length;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> hasOfflineComplaints() async {
    try {
      final count = await getOfflineComplaintCount();
      return count > 0;
    } catch (e) {
      return false;
    }
  }
}
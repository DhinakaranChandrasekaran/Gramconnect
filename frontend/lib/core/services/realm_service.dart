import 'local_storage_service.dart';

class RealmService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize local storage service instead of Realm
      await LocalStorageService.initialize();

      _initialized = true;
      print('Realm Service initialized with SQLite backend');
    } catch (e) {
      print('Failed to initialize Realm Service: $e');
    }
  }

  static Future<void> dispose() async {
    await LocalStorageService.dispose();
    _initialized = false;
  }

  // Sync operations using SQLite backend
  static Future<void> syncComplaint(Map<String, dynamic> complaintData) async {
    await LocalStorageService.saveComplaintDraft(
      complaintData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      complaintData,
    );
  }

  static Future<void> syncNotifications(List<Map<String, dynamic>> notifications) async {
    await LocalStorageService.cacheNotifications(notifications);
  }

  static Future<List<Map<String, dynamic>>> getOfflineComplaints() async {
    final drafts = await LocalStorageService.getComplaintDrafts();
    return drafts.map((draft) => draft['data'] as Map<String, dynamic>).toList();
  }

  static Future<void> cacheData(String key, Map<String, dynamic> data) async {
    if (key == 'schedules' && data['schedules'] != null) {
      await LocalStorageService.cacheSchedules(
        List<Map<String, dynamic>>.from(data['schedules']),
      );
    }
  }

  static Future<Map<String, dynamic>?> getCachedData(String key) async {
    if (key == 'schedules') {
      final schedules = await LocalStorageService.getCachedSchedules();
      return {'schedules': schedules};
    }
    return null;
  }

  static Future<void> clearCache() async {
    // Clear all cached data
    print('Clearing local cache');
  }
}
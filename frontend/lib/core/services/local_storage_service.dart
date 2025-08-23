import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalStorageService {
  static Database? _database;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'gramconnect.db');

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          // Create tables for offline storage
          await db.execute('''
            CREATE TABLE complaint_drafts (
              id TEXT PRIMARY KEY,
              data TEXT NOT NULL,
              created_at INTEGER NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE cached_schedules (
              id TEXT PRIMARY KEY,
              data TEXT NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE cached_notifications (
              id TEXT PRIMARY KEY,
              data TEXT NOT NULL,
              read INTEGER DEFAULT 0,
              created_at INTEGER NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE sync_queue (
              id TEXT PRIMARY KEY,
              type TEXT NOT NULL,
              data TEXT NOT NULL,
              created_at INTEGER NOT NULL
            )
          ''');
        },
      );

      _initialized = true;
      print('Local Storage Service initialized successfully');
    } catch (e) {
      print('Failed to initialize Local Storage: $e');
    }
  }

  static Future<void> dispose() async {
    await _database?.close();
    _database = null;
    _initialized = false;
  }

  // Complaint drafts
  static Future<void> saveComplaintDraft(String id, Map<String, dynamic> data) async {
    if (_database == null) return;

    await _database!.insert(
      'complaint_drafts',
      {
        'id': id,
        'data': jsonEncode(data),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getComplaintDrafts() async {
    if (_database == null) return [];

    final List<Map<String, dynamic>> maps = await _database!.query('complaint_drafts');
    return maps.map((map) => {
      'id': map['id'],
      'data': jsonDecode(map['data']),
      'created_at': DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    }).toList();
  }

  static Future<void> deleteComplaintDraft(String id) async {
    if (_database == null) return;
    await _database!.delete('complaint_drafts', where: 'id = ?', whereArgs: [id]);
  }

  // Cache schedules
  static Future<void> cacheSchedules(List<Map<String, dynamic>> schedules) async {
    if (_database == null) return;

    final batch = _database!.batch();
    for (final schedule in schedules) {
      batch.insert(
        'cached_schedules',
        {
          'id': schedule['id'],
          'data': jsonEncode(schedule),
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  static Future<List<Map<String, dynamic>>> getCachedSchedules() async {
    if (_database == null) return [];

    final List<Map<String, dynamic>> maps = await _database!.query('cached_schedules');
    return maps.map((map) => jsonDecode(map['data']) as Map<String, dynamic>).toList();
  }

  // Cache notifications
  static Future<void> cacheNotifications(List<Map<String, dynamic>> notifications) async {
    if (_database == null) return;

    final batch = _database!.batch();
    for (final notification in notifications) {
      batch.insert(
        'cached_notifications',
        {
          'id': notification['id'],
          'data': jsonEncode(notification),
          'read': notification['read'] ? 1 : 0,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  static Future<List<Map<String, dynamic>>> getCachedNotifications() async {
    if (_database == null) return [];

    final List<Map<String, dynamic>> maps = await _database!.query(
      'cached_notifications',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) {
      final data = jsonDecode(map['data']) as Map<String, dynamic>;
      data['read'] = map['read'] == 1;
      return data;
    }).toList();
  }

  // Sync queue
  static Future<void> addToSyncQueue(String type, Map<String, dynamic> data) async {
    if (_database == null) return;

    await _database!.insert('sync_queue', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'data': jsonEncode(data),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<List<Map<String, dynamic>>> getSyncQueue() async {
    if (_database == null) return [];

    final List<Map<String, dynamic>> maps = await _database!.query(
      'sync_queue',
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => {
      'id': map['id'],
      'type': map['type'],
      'data': jsonDecode(map['data']),
      'created_at': DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    }).toList();
  }

  static Future<void> removeSyncQueueItem(String id) async {
    if (_database == null) return;
    await _database!.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearSyncQueue() async {
    if (_database == null) return;
    await _database!.delete('sync_queue');
  }
}
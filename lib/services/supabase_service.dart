import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://whitusrdpprsxgtntvrw.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndoaXR1c3JkcHByc3hndG50dnJ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc1NjU1MTQsImV4cCI6MjA5MzE0MTUxNH0.RTAuE8ZhH5Uh6RRKA17znXRiCzllTuKDx89KDx0OxkQ';
}

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    debugPrint('✅ Supabase initialized');
  }

  // ── Fetch all rows ────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> fetchAll(
    String table, {
    String? orderBy,
    bool ascending = false,
  }) async {
    try {
      final data = await client.from(table).select();
      var result = List<Map<String, dynamic>>.from(data);

      // Sort
      if (orderBy != null && result.isNotEmpty) {
        result.sort((a, b) {
          final av = a[orderBy]?.toString() ?? '';
          final bv = a[orderBy]?.toString() ?? '';
          return ascending ? av.compareTo(bv) : bv.compareTo(av);
        });
      } else if (result.isNotEmpty && result.first.containsKey('created_at')) {
        result.sort((a, b) {
          final av = a['created_at']?.toString() ?? '';
          final bv = b['created_at']?.toString() ?? '';
          return bv.compareTo(av);
        });
      }

      debugPrint('📦 fetchAll($table): ${result.length} rows');
      return result;
    } on PostgrestException catch (e) {
      debugPrint('❌ fetchAll($table): ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ fetchAll($table): $e');
      rethrow;
    }
  }

  // ── Insert ────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final payload = Map<String, dynamic>.from(data)
        ..removeWhere(
          (k, v) => k == 'id' && (v == null || v.toString().isEmpty),
        );
      final res = await client.from(table).insert(payload).select().single();
      debugPrint('✅ insert($table)');
      return res;
    } on PostgrestException catch (e) {
      debugPrint('❌ insert($table): ${e.message}');
      rethrow;
    }
  }

  // ── Update ────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final payload = Map<String, dynamic>.from(data)
        ..removeWhere((k, _) => k == 'id' || k == 'created_at');
      final res = await client
          .from(table)
          .update(payload)
          .eq('id', id)
          .select()
          .single();
      debugPrint('✅ update($table/$id)');
      return res;
    } on PostgrestException catch (e) {
      debugPrint('❌ update($table/$id): ${e.message}');
      rethrow;
    }
  }

  // ── Delete ────────────────────────────────────────────────────
  static Future<void> delete(String table, String id) async {
    try {
      await client.from(table).delete().eq('id', id);
      debugPrint('✅ delete($table/$id)');
    } on PostgrestException catch (e) {
      debugPrint('❌ delete($table/$id): ${e.message}');
      rethrow;
    }
  }

  // ── Test connection ───────────────────────────────────────────
  static Future<bool> testConnection() async {
    try {
      await client.from('companies').select('id').limit(1);
      return true;
    } catch (_) {
      return false;
    }
  }
}

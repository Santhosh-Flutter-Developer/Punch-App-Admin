import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_app_admin/routes/app_routes.dart';
import 'package:punch_app_admin/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final Rx<Map<String, dynamic>?> currentUser = Rx(null);
  final Rx<Map<String, dynamic>?> currentCompany = Rx(null);
  final RxString errorMsg = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkSession();
  }

  // ── Check existing Supabase session on app start ──────────────
  Future<void> checkSession() async {
    try {
      final session = SupabaseService.client.auth.currentSession;
      if (session != null && session.user.email != null) {
        debugPrint('🔄 Existing session found: ${session.user.email}');
        // Only restore session for the designated super admin
        if (session.user.email == _superAdminEmail) {
          await loadUserByEmail(session.user.email!);
        } else {
          debugPrint('⛔ Session belongs to non-admin user — signing out');
          await SupabaseService.client.auth.signOut();
        }
      }
    } catch (e) {
      debugPrint("_checkSession error: $e");
    }
  }

  // ── Allowed super admin credentials ──────────────────────────
  static const String _superAdminEmail = 'admin@srisoftwarez.com';
  static const String _superAdminPassword = 'Admin@123';

  // ── Main login ────────────────────────────────────────────────
  Future<void> login(String input, String password) async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      final trimmed = input.trim();
      debugPrint('🔐 Login attempt: $trimmed');

      // Step 0: Only allow the designated super admin credentials
      if (trimmed != _superAdminEmail || password != _superAdminPassword) {
        errorMsg.value = 'Access denied. Invalid super admin credentials.';
        return;
      }

      // Step 1: Find user row by email OR username
      Map<String, dynamic>? userRow;

      // Try email first
      final byEmail = await SupabaseService.client
          .from('users')
          .select('*')
          .eq('email', trimmed)
          .limit(1);
      if (byEmail.isNotEmpty) {
        userRow = Map<String, dynamic>.from(byEmail.first);
        debugPrint('✅ Found by email');
      } else {
        // Try username
        final byUsername = await SupabaseService.client
            .from('users')
            .select('*')
            .eq('username', trimmed)
            .limit(1);

        if (byUsername.isNotEmpty) {
          userRow = Map<String, dynamic>.from(byUsername.first);
          debugPrint('✅ Found by username');
        }
      }

      // Step 2: User not found
      if (userRow == null) {
        errorMsg.value = 'No account found. Check your email or username.';
        return;
      }

      debugPrint(
        '👤 User found: ${userRow['full_name']} | is_admin: ${userRow['is_admin']}',
      );

      // Step 3: Check super admin
      if (userRow['is_admin'] != true) {
        errorMsg.value = 'Access denied. Super Admins only.';
        return;
      }

      // Step 4: Sign in via Supabase Auth
      final email = userRow['email']?.toString() ?? '';
      if (email.isEmpty) {
        errorMsg.value = 'No email linked to this account.';
        return;
      }

      try {
        final res = await SupabaseService.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (res.user == null) {
          errorMsg.value = 'Incorrect password. Please try again.';
          return;
        }
        debugPrint('✅ Supabase Auth OK: ${res.user!.email}');
      } on AuthException catch (e) {
        debugPrint('AuthException: ${e.message}');
        if (e.message.toLowerCase().contains('invalid') ||
            e.message.toLowerCase().contains('wrong') ||
            e.message.toLowerCase().contains('credentials')) {
          errorMsg.value = 'Incorrect password. Please try again.';
          return;
        }
        // Other auth errors — still allow if user row found and is_admin
        // (handles edge case where auth user not set up)
        debugPrint('⚠️ Auth error but continuing: ${e.message}');
      }

      // Step 5: Load company
      currentUser.value = userRow;
      await loadCompany(userRow['company_id']?.toString());
      isLoggedIn.value = true;

      debugPrint('🎉 Logged in as: ${userRow['full_name']}');
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      debugPrint('❌ Login error: $e');
      errorMsg.value = 'Login failed: ${friendly(e.toString())}';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Load user by email (for session restore) ──────────────────
  Future<void> loadUserByEmail(String email) async {
    try {
      final rows = await SupabaseService.client
          .from('users')
          .select('*')
          .eq('email', email)
          .limit(1);

      if (rows.isNotEmpty) {
        final u = Map<String, dynamic>.from(rows.first);
        if (u['is_admin'] == true) {
          currentUser.value = u;
          await loadCompany(u['company_id']?.toString());
          isLoggedIn.value = true;
          Get.offAllNamed(AppRoutes.dashboard);
          debugPrint('✅ Session restored for: ${u['full_name']}');
        }
      }
    } catch (e) {
      debugPrint('_loadUserByEmail error: $e');
    }
  }

  // ── Load company ──────────────────────────────────────────────
  Future<void> loadCompany(String? id) async {
    if (id == null || id.isEmpty) return;
    try {
      final rows = await SupabaseService.client
          .from('companies')
          .select('id,name,city,email,phone,is_active')
          .eq('id', id)
          .limit(1);
      if (rows.isNotEmpty) {
        currentCompany.value = Map<String, dynamic>.from(rows.first);
        debugPrint('🏢 Company loaded: ${currentCompany.value!['name']}');
      }
    } catch (e) {
      debugPrint('_loadCompany error: $e');
    }
  }

  // ── Logout ────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await SupabaseService.client.auth.signOut();
    } catch (_) {}
    currentUser.value = null;
    currentCompany.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed(AppRoutes.login);
    debugPrint('👋 Logged out');
  }

  // ── Getters ───────────────────────────────────────────────────
  String get adminName =>
      currentUser.value?['full_name']?.toString().isNotEmpty == true
      ? currentUser.value!['full_name']
      : currentUser.value?['username'] ?? 'Super Admin';

  String get adminEmail => currentUser.value?['email'] ?? '';

  String get companyName => currentCompany.value?['name'] ?? 'Punch App';

  String get adminInitials {
    final name = adminName.trim();
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'SA';
  }

  String friendly(String msg) {
    if (msg.contains('JWT') || msg.contains('Invalid login')) {
      return 'Invalid credentials.';
    }
    if (msg.contains('network') || msg.contains('Socket')) {
      return 'Network error. Check your connection.';
    }
    if (msg.contains('RLS') ||
        msg.contains('permission') ||
        msg.contains('policy')) {
      return 'Database permission error. Check Supabase RLS policies.';
    }
    return msg.replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:punch_app_admin/presentation/auth/login/widgets/branding_panel.dart';
import 'package:punch_app_admin/presentation/auth/login/widgets/login_form.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final RxBool obscure = true.obs;

  @override
  void dispose() {
    userCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0F172A),
        statusBarIconBrightness: Brightness.light,
      ),
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          body: isWide
              ? _wideLayout()
              : _narrowLayout(),
        ),
      ),
    );
  }

  Widget _wideLayout() {
    return Row(
      children: [
        // Left branding panel
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const BrandingPanel(),
          ),
        ),
        // Right form panel
        Container(
          width: 480,
          color: Colors.white,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: LoginForm(
                formKey: formKey,
                userCtrl: userCtrl,
                passCtrl: passCtrl,
                obscure: obscure,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _narrowLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 380,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const BrandingPanel(),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: LoginForm(
              formKey: formKey,
              userCtrl: userCtrl,
              passCtrl: passCtrl,
              obscure: obscure,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/validators.dart'; // sesuaikan path dengan lokasi validators.dart
import '../routes/app_routes.dart';

class UnandspaceCampusAuthentication extends StatefulWidget {
  const UnandspaceCampusAuthentication({super.key});

  @override
  State<UnandspaceCampusAuthentication> createState() =>
      _UnandspaceCampusAuthenticationState();
}

class _UnandspaceCampusAuthenticationState
    extends State<UnandspaceCampusAuthentication> {
  final _formKey = GlobalKey<FormState>(); // (1)
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _remember = false;

  static const _green = Color(0xFF006948);
  static const _fieldBg = Color(0xFFF2F4F6);

  InputDecoration _decoration(IconData icon, {Widget? suffix}) =>
      InputDecoration(
        filled: true,
        fillColor: _fieldBg,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  @override
  void dispose() { // (2)
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() { // (3)
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

     Navigator.pushReplacementNamed(context, AppRoutes.home);

  }

  @override
  Widget build(BuildContext context) {
    final text = GoogleFonts.plusJakartaSansTextTheme();
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: -100, top: -96,
              child: Container(
                width: 288, height: 288,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0x33ADEDD3)),
              ),
            ),
            Positioned(
              left: -80, bottom: -60,
              child: Container(
                width: 320, height: 320,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0x3F85F8C4)),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0x99ADEDD3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.school, color: _green),
                  ),
                  const SizedBox(height: 12),
                  Text('Selamat Datang di\nUnandSpace',
                      textAlign: TextAlign.center,
                      style: text.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Masuk dengan akun email kampus Unand',
                      style: text.bodySmall),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form( // (4)
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email Kampus', style: text.labelMedium),
                            const SizedBox(height: 6),
                            TextFormField( // (5)
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _decoration(Icons.mail_outline),
                              validator: Validators.email,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Kata Sandi', style: text.labelMedium),
                                Text('Lupa kata sandi?',
                                    style: text.labelSmall?.copyWith(
                                        color: _green,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextFormField( // (5)
                              controller: _password,
                              obscureText: _obscure,
                              validator: Validators.password,
                              decoration: _decoration(
                                Icons.lock_outline,
                                suffix: IconButton(
                                  icon: Icon(_obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(children: [
                              Checkbox(
                                value: _remember,
                                activeColor: _green,
                                onChanged: (v) =>
                                    setState(() => _remember = v ?? false),
                              ),
                              Text('Ingat saya', style: text.bodySmall),
                            ]),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _submit, // (6)
                                label: const Text('Masuk'),
                                icon: const Icon(Icons.arrow_forward, size: 18),
                                iconAlignment: IconAlignment.end,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text.rich(TextSpan(
                                text: 'Belum punya akun? ',
                                style: text.bodySmall,
                                children: const [
                                  TextSpan(
                                      text: 'Daftar',
                                      style: TextStyle(color: _green)),
                                ],
                              )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('© 2026 Universitas Andalas', style: text.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
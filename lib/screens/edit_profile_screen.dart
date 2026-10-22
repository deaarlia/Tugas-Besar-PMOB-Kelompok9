import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_profile.dart';
import '../theme/app_theme.dart';

/// Layar edit profil — mengembalikan [UserProfile] yang sudah diperbarui
/// saat pengguna menekan "Simpan Perubahan".
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.initial});

  final UserProfile initial;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const int _bioMaxChars = 160;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _linkedinCtrl;
  late bool _hideYear;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _nameCtrl = TextEditingController(text: p.fullName);
    _usernameCtrl = TextEditingController(text: p.username);
    _bioCtrl = TextEditingController(text: p.bio);
    _linkedinCtrl = TextEditingController(text: p.linkedinUrl);
    _hideYear = p.hideYearFromPublic;

    _bioCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    _linkedinCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    // Validasi sederhana
    if (_nameCtrl.text.trim().isEmpty) {
      _showError('Nama lengkap tidak boleh kosong.');
      return;
    }
    if (_usernameCtrl.text.trim().isEmpty) {
      _showError('Username tidak boleh kosong.');
      return;
    }

    setState(() => _saving = true);
    // Simulasi delay simpan (misal ke API)
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    final updated = widget.initial.copyWith(
      fullName: _nameCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      linkedinUrl: _linkedinCtrl.text.trim(),
      hideYearFromPublic: _hideYear,
    );

    Navigator.of(context).pop(updated);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = widget.initial;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Edit Profil',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: Color(0xFF1B1F1D))),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1F1D)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ─── Avatar ───────────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primaryLight,
                      child: p.avatarAsset != null
                          ? null
                          : const Icon(Icons.person,
                              size: 44, color: AppColors.primary),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: const Icon(Icons.camera_alt,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Ubah Foto Profil',
                    style: text.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
                Text('JPG, PNG atau WebP (Maks. 5MB)',
                    style: text.labelSmall
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ─── Nama Lengkap ─────────────────────────────────────────────────
          _SectionLabel(text: text, label: 'NAMA LENGKAP'),
          const SizedBox(height: 6),
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Nama lengkap'),
          ),
          const SizedBox(height: 16),

          // ─── Username ─────────────────────────────────────────────────────
          _SectionLabel(text: text, label: 'USERNAME / HANDLE'),
          const SizedBox(height: 6),
          TextField(
            controller: _usernameCtrl,
            decoration: InputDecoration(
              hintText: 'username',
              prefixText: '@ ',
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _usernameCtrl,
                builder: (_, val, _x) => val.text.isNotEmpty
                    ? const Icon(Icons.check_circle,
                        color: AppColors.primary)
                    : const SizedBox.shrink(),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-Z0-9_\.]')),
            ],
          ),
          const SizedBox(height: 16),

          // ─── Bio ─────────────────────────────────────────────────────────
          _SectionLabel(text: text, label: 'BIO / DESKRIPSI DIRI'),
          const SizedBox(height: 6),
          TextField(
            controller: _bioCtrl,
            maxLines: 4,
            maxLength: _bioMaxChars,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                Text(
                  '$currentLength/${maxLength ?? _bioMaxChars}',
                  style: text.labelSmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
            decoration: const InputDecoration(
              hintText: 'Ceritakan sedikit tentang dirimu...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),

          // ─── Jurusan & Angkatan (locked) ──────────────────────────────────
          _SectionLabel(
            text: text,
            label: 'JURUSAN & ANGKATAN',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('Terverifikasi SIA',
                    style: text.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.school_outlined,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(p.yearLabel,
                    style: text.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary)),
                const Spacer(),
                const Icon(Icons.lock_outline,
                    size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF7F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    size: 15, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${p.username}@student.unand.ac.id',
                          style: text.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                        'Data terintegrasi otomatis dengan akun SIA Unand. '
                        'Hubungi bagian akademik fakultas untuk pembaruan '
                        'program studi.',
                        style: text.labelSmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── LinkedIn ─────────────────────────────────────────────────────
          _SectionLabel(
              text: text, label: 'TAUTAN PROFIL LINKEDIN (OPSIONAL)'),
          const SizedBox(height: 6),
          TextField(
            controller: _linkedinCtrl,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              prefixIcon:
                  Icon(Icons.link, size: 18, color: AppColors.primary),
              hintText: 'linkedin.com/in/username',
            ),
          ),
          const SizedBox(height: 24),

          // ─── Privasi ─────────────────────────────────────────────────────
          const _SectionDivider(),
          const SizedBox(height: 16),
          Text('Privasi & Akses Komunitas',
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sembunyikan Angkatan di Profil Publik',
                        style: text.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      'Tahun masuk hanya akan terlihat oleh rekan seangkatan dan dosen.',
                      style: text.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: _hideYear,
                activeThumbColor: AppColors.primary,
                onChanged: (v) => setState(() => _hideYear = v),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ─── Panduan ─────────────────────────────────────────────────────
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.shield_outlined,
                        size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Panduan Profil UnandConnect',
                            style: text.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        Text(
                          'Gunakan nama serta foto profil yang sopan sesuai etika kampus.',
                          style: text.bodySmall?.copyWith(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ─── Tombol Simpan ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saving ? null : _simpan,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_outlined, size: 18),
              label:
                  Text(_saving ? 'Menyimpan...' : 'Simpan Perubahan',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batalkan',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Helper widgets ──────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(
      {required this.text, required this.label, this.trailing});
  final TextTheme text;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: text.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4)),
        if (trailing != null) ...[const Spacer(), trailing!],
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(color: AppColors.divider, thickness: 1, height: 1);
  }
}

// Paket Flutter Material (widget UI)
import 'package:flutter/material.dart';
// Package Provider untuk state management
import 'package:provider/provider.dart';

// Model laporan
import '../models/report.dart';
// Model alasan laporan
import '../models/report_reason.dart';
// Model target konten yang dilaporkan
import '../models/report_target.dart';
// Provider state dan validasi form laporan
import '../viewmodels/report_form_view_model.dart';
// Repository laporan (untuk dibaca oleh provider)
import '../repositories/report_repository.dart';
// Tema aplikasi
import '../theme/app_theme.dart';
// Layar sukses setelah laporan terkirim
import 'report_success_screen.dart';

// =============================================================================
// INPUT / EVENT (FR-04): Halaman form laporan konten.
//
// Alur:
//   1. Menerima [target] (konten yang dilaporkan) dari layar sebelumnya.
//   2. Pengguna memilih alasan dan mengisi keterangan.
//   3. Pengguna menekan tombol "Kirim Laporan".
//   4. Setelah berhasil, membuka layar sukses, lalu kembali dengan [Report].
// =============================================================================

/// Halaman form laporan ("Laporan Konten" di Figma).
///
/// Menerima [target] dari layar sebelumnya. Setelah kirim berhasil, membuka
/// layar sukses, lalu mengembalikan [Report] lewat Navigator.pop.
class ReportFormScreen extends StatelessWidget {
  const ReportFormScreen({super.key, required this.target});

  // Data konten yang akan dilaporkan (dikirim dari layar utas/komentar)
  final ReportTarget target;

  @override
  Widget build(BuildContext context) {
    // Buat instance ReportFormViewModel baru untuk setiap pembukaan form
    // agar form selalu mulai dari kondisi kosong
    return ChangeNotifierProvider<ReportFormViewModel>(
      create: (BuildContext ctx) => ReportFormViewModel(
        repository: ctx.read<ReportRepository>(),
        target: target,
      ),
      child: _ReportFormView(target: target),
    );
  }
}

// Widget stateful internal yang menampilkan form laporan.
// Dipisah dari ReportFormScreen agar Provider tersedia di subtree.
class _ReportFormView extends StatefulWidget {
  const _ReportFormView({required this.target});

  // Data konten yang dilaporkan
  final ReportTarget target;

  @override
  State<_ReportFormView> createState() => _ReportFormViewState();
}

class _ReportFormViewState extends State<_ReportFormView> {
  // Controller untuk field keterangan tambahan
  final TextEditingController _descriptionController = TextEditingController();

  // Key untuk scroll otomatis ke field yang bermasalah saat validasi gagal
  final GlobalKey _reasonKey = GlobalKey(); // Key untuk bagian alasan
  final GlobalKey _descriptionKey = GlobalKey(); // Key untuk bagian keterangan
  final GlobalKey _formErrorKey = GlobalKey(); // Key untuk banner error form

  @override
  void dispose() {
    // Bebaskan controller dari memori saat widget dihapus
    _descriptionController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // INPUT / EVENT: Pengguna menekan tombol "Kirim Laporan".
  //
  // Alur:
  //   1. Tutup keyboard agar tidak menghalangi tampilan
  //   2. Panggil form.submit() untuk memvalidasi dan mengirim
  //   3. Jika berhasil (report != null):
  //      - NAVIGATION: Buka layar sukses
  //      - NAVIGATION / RESULT: Kembali ke layar sebelumnya dengan report
  //   4. Jika gagal:
  //      - FEEDBACK: Scroll ke field yang bermasalah agar error terlihat
  // ---------------------------------------------------------------------------
  /// INPUT / EVENT: pengguna menekan Kirim Laporan.
  Future<void> _submit() async {
    // Tutup keyboard sebelum memproses
    FocusScope.of(context).unfocus();
    final NavigatorState navigator = Navigator.of(context);
    final ReportFormViewModel form = context.read<ReportFormViewModel>();

    // Jalankan submit (validasi + kirim ke repository)
    final Report? report = await form.submit();
    if (!mounted) return;

    if (report != null) {
      // NAVIGATION: tampilkan layar sukses (membawa report),
      // lalu kembali ke layar utas membawa report sebagai result.
      final Report? done = await navigator.push<Report>(
        MaterialPageRoute<Report>(
          builder: (_) => ReportSuccessScreen(report: report),
        ),
      );
      if (!mounted) return;
      // NAVIGATION / RESULT: Kembalikan report ke layar sebelumnya (layar utas)
      navigator.pop(done ?? report);
      return;
    }

    // FEEDBACK: Gagal — gulir ke field yang bermasalah supaya pesan error terlihat.
    final GlobalKey? errorKey = form.reasonError != null
        ? _reasonKey // Ada error pada field alasan
        : form.descriptionError != null
        ? _descriptionKey // Ada error pada field keterangan
        : form.formError != null
        ? _formErrorKey // Ada error tingkat form (contoh: laporan ganda)
        : null;
    final BuildContext? errorContext = errorKey?.currentContext;
    if (errorContext != null && errorContext.mounted) {
      // Scroll animasi ke widget yang bermasalah
      Scrollable.ensureVisible(
        errorContext,
        duration: const Duration(milliseconds: 300),
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider agar widget rebuild saat state berubah
    final ReportFormViewModel form = context.watch<ReportFormViewModel>();
    final ReportTarget target = widget.target;
    final TextTheme text = Theme.of(context).textTheme;
    final Color errorColor = Theme.of(context).colorScheme.error;

    // Hitung panjang keterangan saat ini untuk penghitung karakter
    final int length = form.description.length;
    // True jika keterangan melebihi batas 300 karakter
    final bool isTooLong = length > ReportFormViewModel.maxDescriptionLength;

    return PopScope(
      // STATE: Selama laporan dikirim, tombol kembali dinonaktifkan
      // agar pengguna tidak keluar saat proses pengiriman berlangsung.
      canPop: !form.isSubmitting,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Laporan Konten'),
              Text(
                'UnandSpace',
                style: text.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: const <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryLight,
                child: Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _PrivacyBanner(),
                const Divider(height: 32),
                Text(
                  'KONTEN YANG DILAPORKAN',
                  style: text.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 10),
                _TargetPreview(target: target),
                const Divider(height: 32),
                // Bagian alasan laporan: diberi key untuk scroll saat error
                KeyedSubtree(
                  key: _reasonKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Label bagian alasan
                      Text(
                        'Pilih Alasan Pelaporan',
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Instruksi memilih alasan
                      Text(
                        'Pilih kategori pelanggaran yang paling sesuai '
                        'dengan konten di atas:',
                        style: text.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // INPUT: Daftar pilihan alasan laporan (tile yang bisa diklik)
                      for (final ReportReason reason in ReportReason.values)
                        _ReasonTile(
                          reason: reason,
                          selected: form.reason == reason,
                          // Nonaktifkan saat sedang mengirim untuk cegah perubahan
                          onTap: form.isSubmitting
                              ? null
                              : () => form.selectReason(reason),
                        ),
                      // FEEDBACK: Tampilkan error di bawah daftar alasan jika tidak dipilih
                      if (form.reasonError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 8),
                          child: Text(
                            form.reasonError!,
                            style: text.bodySmall?.copyWith(color: errorColor),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                // Bagian keterangan tambahan: diberi key untuk scroll saat error
                KeyedSubtree(
                  key: _descriptionKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'Keterangan Tambahan ',
                                style: text.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: <InlineSpan>[
                                  // VALIDATION: Tanda (Wajib) jika alasan "Lainnya"
                                  TextSpan(
                                    text: form.isDescriptionRequired
                                        ? '(Wajib)'
                                        : '(Opsional)',
                                    style: text.bodySmall?.copyWith(
                                      // Warna merah jika wajib diisi
                                      color: form.isDescriptionRequired
                                          ? errorColor
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // STATE: Penghitung karakter realtime (n/300)
                          Text(
                            '$length/${ReportFormViewModel.maxDescriptionLength}',
                            style: text.bodySmall?.copyWith(
                              // Warna merah jika melebihi batas
                              color: isTooLong
                                  ? errorColor
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // INPUT: Field keterangan tambahan
                      TextField(
                        controller: _descriptionController,
                        enabled: !form.isSubmitting, // Nonaktif saat mengirim
                        minLines: 4,
                        maxLines: 6,
                        textInputAction: TextInputAction.newline,
                        onChanged:
                            form.setDescription, // Update state saat mengetik
                        decoration: InputDecoration(
                          hintText:
                              'Berikan rincian singkat agar tim '
                              'moderasi memahami konteks laporan...',
                          hintStyle: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          // FEEDBACK: Pesan error di bawah field keterangan
                          errorText: form.descriptionError,
                          counterText: '', // counter sudah di baris judul
                        ),
                      ),
                    ],
                  ),
                ),
                // FEEDBACK: Banner error tingkat form (contoh: laporan ganda)
                // Diberi key untuk scroll otomatis saat muncul
                if (form.formError != null) ...<Widget>[
                  const SizedBox(height: 16),
                  KeyedSubtree(
                    key: _formErrorKey,
                    child: _ErrorBanner(message: form.formError!),
                  ),
                ],
                const Divider(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(Icons.info, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Laporan Anda bersifat 100% anonim dan diteruskan '
                        'ke Tim Moderasi UnandSpace.',
                        style: text.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Tombol Kirim Laporan
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    // STATE: null = nonaktif selama loading, mencegah kirim ganda.
                    onPressed: form.isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      disabledBackgroundColor: AppColors.primary,
                      disabledForegroundColor: Colors.white,
                    ),
                    // STATE: Tampilkan spinner saat sedang mengirim
                    child: form.isSubmitting
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Mengirim...'),
                            ],
                          )
                        // Tampilan normal saat tidak mengirim
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.send_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Kirim Laporan'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: TextButton(
                    onPressed: form.isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text('Batalkan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyBanner extends StatelessWidget {
  const _PrivacyBanner();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primaryLight,
          child: Icon(Icons.verified_user, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Privasi Anda Terjamin',
                style: text.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Laporan bersifat rahasia & anonim. Pengguna yang '
                'dilaporkan tidak akan mengetahui identitas Anda.',
                style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pratinjau konten yang dilaporkan (data yang dikirim dari layar sebelumnya).
class _TargetPreview extends StatelessWidget {
  const _TargetPreview({required this.target});

  final ReportTarget target;

  String get _initials {
    final List<String> parts = target.authorName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.chipBackground,
              child: Text(
                _initials,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                target.authorName,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (target.communityName != null) ...<Widget>[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '• ${target.communityName}',
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(width: 3, color: AppColors.primary),
              Expanded(
                child: Container(
                  color: AppColors.surfaceAlt,
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    '"${target.excerpt}"',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF3A4540),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Satu opsi alasan: judul + deskripsi, radio di kanan (gaya Figma).
class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.reason,
    required this.selected,
    required this.onTap,
  });

  final ReportReason reason;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      button: true,
      label: '${reason.label}. ${reason.description}',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      reason.label,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected ? AppColors.primary : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reason.description,
                      style: text.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.error_outline, color: scheme.onErrorContainer, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

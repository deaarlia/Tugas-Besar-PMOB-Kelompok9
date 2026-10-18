import 'package:flutter/material.dart';

import '../data/placeholder_data.dart';
import '../models/report_target.dart';
import '../theme/app_theme.dart';
import '../widgets/report_menu.dart';
import '../widgets/thread_options_sheet.dart';

class _DemoComment {
  const _DemoComment(this.id, this.author, this.badge, this.time, this.body,
      {this.best = false, this.votes = 0});

  final String id, author, badge, time, body;
  final bool best;
  final int votes;
}

/// Komentar demo per utas. Utas yang tidak ada di peta ini tidak punya komentar.
const Map<String, List<_DemoComment>> _commentsByThread =
    <String, List<_DemoComment>>{
  'thread-2': <_DemoComment>[
    _DemoComment(
      'comment-1',
      'Rahmat Hidayat',
      'BEM KM Unand',
      'Farmasi \'20 • 2 jam lalu',
      'Izin menjawab Kak Aisyah! Mulai semester genap kemarin, alur pengajuan '
          'cuti sudah full online terintegrasi melalui laman SIA. Ajukan menu '
          '"Permohonan Cuti" sebelum batas akhir KRS, approval dosen PA via '
          'sistem SIA Dosen, lalu dekan menerbitkan SK Cuti digital.',
      best: true,
      votes: 48,
    ),
    _DemoComment(
      'comment-2',
      'Fajar Nugraha',
      'Teknologi Informasi \'22',
      '45 menit lalu',
      'Menambahkan info dari Kak Rahmat, pastikan juga tidak ada tanggungan '
          'peminjaman buku perpustakaan pusat di Gedung PKM.',
      votes: 5,
    ),
  ],
};

class ThreadDetailScreen extends StatefulWidget {
  const ThreadDetailScreen({super.key, required this.post});

  final DemoPost post;

  @override
  State<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends State<ThreadDetailScreen> {
  bool _newest = false;

  /// INPUT: tekan "Laporkan" -> alur bersama (showReportFlow): kirim target ke
  /// form, lalu snackbar "Laporan berhasil dikirim" dengan aksi "Lihat".
  Future<void> _openReport(ReportTarget target) =>
      showReportFlow(context, target);

  void _threadMenu() {
    final DemoPost p = widget.post;
    showContentOptionsSheet(
      context,
      onReport: () => _openReport(ReportTarget(
        type: ReportTargetType.thread,
        id: p.id,
        excerpt: p.title,
        authorName: p.author,
        communityName: 'Forum ${p.tag}',
      )),
    );
  }

  void _commentMenu(_DemoComment c) {
    showContentOptionsSheet(
      context,
      title: 'Opsi Komentar',
      reportLabel: 'Laporkan Komentar',
      hideLabel: 'Sembunyikan Komentar Ini',
      onReport: () => _openReport(ReportTarget(
        type: ReportTargetType.comment,
        id: c.id,
        excerpt: c.body,
        authorName: c.author,
        communityName: 'Forum ${widget.post.tag}',
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final DemoPost p = widget.post;
    final List<_DemoComment> comments =
        _commentsByThread[p.id] ?? const <_DemoComment>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Utas'),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: _threadMenu),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.chipBackground,
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(p.author,
                              style: text.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          Text('${p.sub} • ${p.time}',
                              style: text.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      onPressed: () {},
                      child: const Text('+ Ikuti'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(p.title,
                    style:
                        text.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Text(p.body, style: text.bodyLarge),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.arrow_upward, size: 18),
                          const SizedBox(width: 4),
                          Text('${p.votes}'),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_downward,
                              size: 18, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.chat_bubble_outline, size: 18),
                          const SizedBox(width: 6),
                          Text('${p.comments} Komentar'),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  children: <Widget>[
                    Text('Diskusi & Komentar ',
                        style: text.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    Text('(${p.comments})',
                        style: text.bodySmall
                            ?.copyWith(color: AppColors.textSecondary)),
                    const Spacer(),
                    _Seg('Terbaik', !_newest,
                        () => setState(() => _newest = false)),
                    _Seg('Terbaru', _newest,
                        () => setState(() => _newest = true)),
                  ],
                ),
                const SizedBox(height: 12),
                if (comments.isEmpty)
                  _EmptyComments(hasComments: p.comments > 0)
                else
                  for (final _DemoComment c
                      in (_newest ? comments.reversed.toList() : comments))
                    _CommentTile(comment: c, onMenu: () => _commentMenu(c)),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: <Widget>[
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.chipBackground,
                    child: Icon(Icons.person, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tulis tanggapan atau jawaban',
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.surfaceAlt,
                        suffixIcon: const Icon(Icons.image_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg(this.label, this.active, this.onTap);

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.primary : AppColors.textSecondary)),
      ),
    );
  }
}

class _EmptyComments extends StatelessWidget {
  const _EmptyComments({required this.hasComments});

  /// True bila utas punya komentar di hitungan, tapi data demonya belum ditulis.
  final bool hasComments;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: <Widget>[
          const Icon(Icons.chat_bubble_outline,
              size: 36, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(
            hasComments
                ? 'Komentar utas ini belum tersedia di data demo.'
                : 'Belum ada jawaban. Jadilah yang pertama menjawab!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, required this.onMenu});

  final _DemoComment comment;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (comment.best)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.check_circle_outline,
                      size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Jawaban Terbaik oleh Penulis',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          Row(
            children: <Widget>[
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.chipBackground,
                child: Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(comment.author,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(comment.badge,
                              style: text.labelSmall
                                  ?.copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    Text(comment.time,
                        style: text.bodySmall
                            ?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.more_horiz), onPressed: onMenu),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.body, style: text.bodyMedium),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.arrow_upward, size: 16),
                    const SizedBox(width: 4),
                    Text('${comment.votes}'),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_downward,
                        size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.reply, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              const Text('Balas',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
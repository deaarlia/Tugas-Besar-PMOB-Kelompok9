import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kGreen = Color(0xFF006948);
const kBg = Color(0xFFF7F9FB);
const kField = Color(0xFFF2F4F6);
const kBorder = Color(0xFFECEEF0);
const kMint = Color(0xFFB0F0D6);
const kDarkGreen = Color(0xFF0B513D);
const kMuted = Color(0xFF3D4A42);

TextStyle _s(double size, FontWeight w, Color c, {double? h}) =>
    GoogleFonts.plusJakartaSans(
        fontSize: size, fontWeight: w, color: c, height: h);

class Post {
  final String initials, name, tag, time, title, body;
  final int votes, comments;
  final String? location;
  final Color avatarBg, avatarFg;
  final bool readMore;

  const Post({
    required this.initials,
    required this.name,
    required this.tag,
    required this.time,
    required this.title,
    required this.body,
    required this.votes,
    required this.comments,
    required this.avatarBg,
    required this.avatarFg,
    this.location,
    this.readMore = false,
  });
}

const _posts = [
  Post(
    initials: 'FR',
    name: 'Fajar Ramadhan',
    tag: "Information Systems '24",
    time: '2h ago',
    title: 'Bagaimana tips memilih dosen pembimbing skripsi di Fasilkom Unand agar lancar?',
    body: 'Bagi kakak-kakak tingkat yang sudah lulus atau sedang seminar, mohon pencerahannya terkait kriteria dosen pembimbing yang responsif dan bagaimana etika menghubungi beliau pertama kali...',
    votes: 142,
    comments: 28,
    avatarBg: Color(0xFFADEDD3),
    avatarFg: Color(0xFF306D58),
    readMore: true,
  ),
  Post(
    initials: 'AP',
    name: 'Aisyah Putri',
    tag: "Kedokteran '22",
    time: '5h ago',
    title: 'Rekomendasi tempat belajar & nugas yang tenang di sekitar Kampus Limau Manis?',
    body: 'Perpustakaan pusat sering ramai saat minggu UTS. Apakah ada working space atau kafe ramah mahasiswa dengan wifi kencang dan colokan memadai di dekat gerbang unand?',
    votes: 89,
    comments: 0,
    avatarBg: Color(0xFF85F8C4),
    avatarFg: Color(0xFF002114),
    location: 'Gedung Perpustakaan Pusat Lt. 3',
  ),
  Post(
    initials: 'RH',
    name: 'Rian Hidayat',
    tag: "Teknik Elektro '23",
    time: 'Yesterday',
    title: 'Prosedur pengajuan cuti akademik semester ganjil melalui portal akademik unand?',
    body: 'Apakah surat pengantar dari Kaprodi harus diunggah secara online atau diserahkan fisik ke BAAK? Mohon info batas akhir pengajuannya juga rekan-rekan.',
    votes: 45,
    comments: 9,
    avatarBg: Color(0xFFE6E8EA),
    avatarFg: Color(0xFF191C1E),
  ),
];

class UnandspaceMainCampusFeed extends StatelessWidget {
  const UnandspaceMainCampusFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          for (final p in _posts) PostTile(post: p),
                          const _AskCta(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kGreen,
        shape: const CircleBorder(),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: kBg,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          children: [
            const Expanded(child: _NavItem(Icons.home, 'Home', selected: true)),
            const Expanded(child: _NavItem(Icons.groups_outlined, 'Community')),
            const SizedBox(width: 56),
            Expanded(
              child: _NavItem(Icons.notifications_outlined, 'Alerts', badge: 3),
            ),
            const Expanded(child: _NavItem(Icons.person_outline, 'Profile')),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBg,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.school, color: kGreen, size: 32),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(TextSpan(children: [
                      TextSpan(text: 'Unand', style: _s(18, FontWeight.w700, kGreen)),
                      TextSpan(
                          text: 'Space',
                          style: _s(18, FontWeight.w700, const Color(0xFF059669))),
                    ])),
                    Text('Beranda Kampus', style: _s(11, FontWeight.w500, kMuted)),
                  ],
                ),
              ),
              _RoundIcon(Icons.tune, bg: kField, fg: kMuted),
              const SizedBox(width: 8),
              _RoundIcon(Icons.edit_outlined, bg: kGreen, fg: Colors.white),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            style: _s(14, FontWeight.w400, const Color(0xFF191C1E)),
            decoration: InputDecoration(
              hintText: 'Search questions or topics...',
              hintStyle: _s(14, FontWeight.w400, const Color(0xFF6D7A72)),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: const Icon(Icons.mic_none),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final Color bg, fg;
  const _RoundIcon(this.icon, {required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: fg),
      );
}

class PostTile extends StatelessWidget {
  final Post post;
  const PostTile({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final p = post;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: p.avatarBg,
                child: Text(p.initials,
                    style: _s(14, FontWeight.w700, p.avatarFg)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        style: _s(14, FontWeight.w600, const Color(0xFF191C1E))),
                    const SizedBox(height: 2),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: kMint, borderRadius: BorderRadius.circular(99)),
                        child: Text(p.tag, style: _s(10, FontWeight.w500, kDarkGreen)),
                      ),
                      const SizedBox(width: 6),
                      Text('• ${p.time}',
                          style: _s(10, FontWeight.w500, const Color(0xFF94A3B8))),
                    ]),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: Color(0xFF6D7A72)),
            ],
          ),
          const SizedBox(height: 10),
          Text(p.title, style: _s(16, FontWeight.w600, const Color(0xFF191C1E), h: 1.38)),
          const SizedBox(height: 10),
          Text(p.body,
              maxLines: p.readMore ? 4 : null,
              overflow: p.readMore ? TextOverflow.ellipsis : null,
              style: _s(13, FontWeight.w400, const Color(0xFF475569), h: 1.63)),
          if (p.readMore)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Read more', style: _s(13, FontWeight.w600, kGreen)),
            ),
          if (p.location != null) ...[
            const SizedBox(height: 10),
            _LocationCard(p.location!),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              _VotePill(p.votes),
              const Spacer(),
              const Icon(Icons.chat_bubble_outline, size: 16, color: kMuted),
              const SizedBox(width: 4),
              Text(p.comments == 0 ? '' : '${p.comments} comments',
                  style: _s(12, FontWeight.w400, kMuted)),
              const SizedBox(width: 12),
              const Icon(Icons.bookmark_border, size: 20, color: kMuted),
              const SizedBox(width: 12),
              const Icon(Icons.share_outlined, size: 20, color: kMuted),
            ],
          ),
        ],
      ),
    );
  }
}

class _VotePill extends StatelessWidget {
  final int votes;
  const _VotePill(this.votes);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            color: kField, borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: kMint, borderRadius: BorderRadius.circular(99)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.arrow_upward, size: 16, color: kDarkGreen),
              const SizedBox(width: 4),
              Text('$votes', style: _s(12, FontWeight.w600, kDarkGreen)),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(Icons.arrow_downward, size: 16, color: kMuted),
          ),
        ]),
      );
}

class _LocationCard extends StatelessWidget {
  final String label;
  const _LocationCard(this.label);

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(children: [
          Image.network('https://placehold.co/310x128',
              height: 128, width: double.infinity, fit: BoxFit.cover),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(children: [
              const Icon(Icons.location_on, size: 16, color: kGreen),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(label,
                      style: _s(12, FontWeight.w500, const Color(0xFF191C1E)))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: kBorder, borderRadius: BorderRadius.circular(4)),
                child: Text('Lokasi Unand', style: _s(10, FontWeight.w500, kMuted)),
              ),
            ]),
          ),
        ]),
      );
}

class _AskCta extends StatelessWidget {
  const _AskCta();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        color: kField.withOpacity(0.6),
        child: Column(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: kGreen.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.help_outline, color: kGreen),
          ),
          const SizedBox(height: 8),
          Text('Punya pertanyaan seputar kuliah?',
              style: _s(15, FontWeight.w600, const Color(0xFF191C1E))),
          const SizedBox(height: 8),
          Text(
            'Tanyakan langsung ke ribuan rekan mahasiswa dan alumni Universitas Andalas.',
            textAlign: TextAlign.center,
            style: _s(12, FontWeight.w400, kMuted, h: 1.6),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreen,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            onPressed: () {},
            child: Text('Buat Pertanyaan Baru',
                style: _s(13, FontWeight.w500, Colors.white)),
          ),
        ]),
      );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int badge;
  const _NavItem(this.icon, this.label, {this.selected = false, this.badge = 0});

  @override
  Widget build(BuildContext context) {
    final color = selected ? kGreen : kMuted;
    Widget ic = Icon(icon, color: color);
    if (badge > 0) {
      ic = Badge(label: Text('$badge'), child: ic);
    }
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ic,
          const SizedBox(height: 2),
          Text(label, style: _s(11, FontWeight.w700, color)),
        ],
      ),
    );
  }
}
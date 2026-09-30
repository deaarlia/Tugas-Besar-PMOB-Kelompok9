import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/item_repository.dart';
import '../models/item.dart';
import '../routes/app_routes.dart';
import '../widgets/state_views.dart';

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

// (1) status tampilan
enum ViewStatus { loading, success, error }

class UnandspaceMainCampusFeed extends StatefulWidget {
  const UnandspaceMainCampusFeed({super.key});

  @override
  State<UnandspaceMainCampusFeed> createState() =>
      _UnandspaceMainCampusFeedState();
}

class _UnandspaceMainCampusFeedState extends State<UnandspaceMainCampusFeed> {
  // (2) variabel state
  final _repository = ItemRepository();
  ViewStatus _status = ViewStatus.loading;
  List<Item> _items = [];
  String _errorMessage = '';
  bool _simulateError = false; // ubah ke true untuk menguji error state

  // (3) ambil data saat layar pertama kali dibuka
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // (4) mengambil data + menangani error
  Future<void> _loadItems() async {
    if (_status != ViewStatus.loading) {
      setState(() => _status = ViewStatus.loading);
    }
    try {
      final items = await _repository.fetchItems(simulateError: _simulateError);
      if (!mounted) return;
      setState(() {
        _items = items;
        _status = ViewStatus.success;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _status = ViewStatus.error;
      });
    }
  }

  // (6) memilih tampilan: loading / error / daftar data
  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const LoadingView(),
      ViewStatus.error =>
        ErrorView(message: _errorMessage, onRetry: _loadItems),
      ViewStatus.success => _buildList(),
    };
  }

  Widget _buildList() {
    if (_items.isEmpty) {
      return const EmptyView(message: 'Belum ada data.');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length + 1,
      itemBuilder: (context, index) {
        if (index == _items.length) return const _AskCta();
        final item = _items[index];
        return PostTile(
          item: item,
          // (7) kirim item yang dipilih ke layar Detail
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.detail,
            arguments: item,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(child: _buildContent()), // (5)
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
          children: const [
            Expanded(child: _NavItem(Icons.home, 'Home', selected: true)),
            Expanded(child: _NavItem(Icons.groups_outlined, 'Community')),
            SizedBox(width: 56),
            Expanded(
              child: _NavItem(Icons.notifications_outlined, 'Alerts', badge: 3),
            ),
            Expanded(child: _NavItem(Icons.person_outline, 'Profile')),
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
                      TextSpan(
                          text: 'Unand',
                          style: _s(18, FontWeight.w700, kGreen)),
                      TextSpan(
                          text: 'Space',
                          style: _s(
                              18, FontWeight.w700, const Color(0xFF059669))),
                    ])),
                    Text('Beranda Kampus',
                        style: _s(11, FontWeight.w500, kMuted)),
                  ],
                ),
              ),
              const _RoundIcon(Icons.tune, bg: kField, fg: kMuted),
              const SizedBox(width: 8),
              const _RoundIcon(Icons.edit_outlined, bg: kGreen, fg: Colors.white),
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
  final Item item;
  final VoidCallback? onTap;
  const PostTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
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
                    backgroundColor: kMint,
                    child: Text(
                      item.title.isNotEmpty ? item.title[0].toUpperCase() : '?',
                      style: _s(14, FontWeight.w700, kDarkGreen),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item.subtitle,
                        style: _s(12, FontWeight.w500, kMuted)),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF6D7A72)),
                ],
              ),
              const SizedBox(height: 10),
              Text(item.title,
                  style: _s(16, FontWeight.w600, const Color(0xFF191C1E),
                      h: 1.38)),
              const SizedBox(height: 8),
              Text(item.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: _s(13, FontWeight.w400, const Color(0xFF475569),
                      h: 1.63)),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text('Lihat Detail',
                      style: _s(13, FontWeight.w600, kGreen)),
                ),
              ),  
            ],
          ),
        ),
      ),
    );
  }
}

class _AskCta extends StatelessWidget {
  const _AskCta();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        color: kField.withValues(alpha: 0.6),
        child: Column(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: kGreen.withValues(alpha: 0.1), shape: BoxShape.circle),
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
  const _NavItem(this.icon, this.label,
      {this.selected = false, this.badge = 0});

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
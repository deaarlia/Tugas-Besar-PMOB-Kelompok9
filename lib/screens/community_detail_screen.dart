import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/community.dart';
import '../viewmodels/community_list_view_model.dart';
import '../widgets/community_follow_action.dart';

class CommunityDetailScreen extends StatefulWidget {
  final Community community;

  const CommunityDetailScreen({super.key, required this.community});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityListViewModel>(
      builder: (context, provider, child) {
        final currentCommunity = provider.communities.firstWhere(
          (c) => c.id == widget.community.id,
          orElse: () => widget.community,
        );

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200.0,
                  pinned: true,
                  actions: [
                    IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          color: Colors.green.shade800,
                          child: const Center(
                            child: Icon(Icons.landscape, size: 80, color: Colors.white24),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.4),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -35),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.green.shade900,
                                  child: Text(
                                    currentCommunity.initials,
                                    style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Tombol Bergabung / Mengikuti / Keluar Komunitas
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: currentCommunity.isFollowing ? Colors.grey.shade200 : Colors.green.shade800,
                                foregroundColor: currentCommunity.isFollowing ? Colors.black87 : Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 0,
                              ),
                              onPressed: () => handleCommunityFollowTap(context, provider, currentCommunity),
                              icon: Icon(currentCommunity.isFollowing ? Icons.check : Icons.group_add, size: 18),
                              label: Text(currentCommunity.isFollowing ? 'Mengikuti' : 'Bergabung'),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
                              icon: const Icon(Icons.notifications_outlined, size: 20),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
                              icon: const Icon(Icons.share_outlined, size: 20),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        Transform.translate(
                          offset: const Offset(0, -15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    currentCommunity.name,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      currentCommunity.categoryTag,
                                      style: TextStyle(fontSize: 11, color: Colors.green.shade900, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Aktif',
                                      style: TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentCommunity.description,
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.apartment, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('Fakultas Teknologi Informasi • Universitas Andalas', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.groups, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('${currentCommunity.memberCount} Anggota', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.green.shade800,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.green.shade800,
                      tabs: const [
                        Tab(text: 'Utas'),
                        Tab(text: 'Tentang'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // ================= TAB 1: UTAS =================
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.push_pin, size: 14, color: Colors.green.shade800),
                              const SizedBox(width: 6),
                              Text(
                                'DISEMATKAN OLEH PENGURUS • Hari ini',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Pendaftaran Mentoring Pemrograman & Basis Data Semester Genap Telah Dibuka! 🚀',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text('💬 32 balasan', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(radius: 16, child: Text('RP')),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Text('Rafly Pratama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        SizedBox(width: 4),
                                        Text('• 2 jam lalu', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      ],
                                    ),
                                    Text('Sistem Informasi', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                                  ],
                                ),
                                const Spacer(),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    minimumSize: const Size(50, 28),
                                  ),
                                  onPressed: () {},
                                  child: const Text('+ Ikuti', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Ada yang punya silabus praktikum & materi integrasi Cloud Computing untuk arsitektur microservices semester ini? Khususnya hands-on AWS atau Google Cloud yang dibahas di lab SI.',
                              style: TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            const Text('#PraktikumSI #CloudComputing #AkademikUnand', style: TextStyle(color: Colors.green, fontSize: 12)),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(icon: const Icon(Icons.arrow_upward, size: 16), onPressed: () {}),
                                    const Text('42', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    IconButton(icon: const Icon(Icons.arrow_downward, size: 16), onPressed: () {}),
                                  ],
                                ),
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                  label: const Text('12 komentar', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ================= TAB 2: TENTANG =================
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('Informasi Komunitas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 10),
                    _buildInfoTile(Icons.calendar_today, 'Tanggal Dibuat', currentCommunity.createdDate),
                    _buildInfoTile(Icons.location_on_outlined, 'Lokasi', currentCommunity.location),
                    _buildInfoTile(Icons.link, 'Tautan & Saluran Resmi', currentCommunity.officialLinks.join('\n')),
                    const Divider(height: 24),
                    const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text(currentCommunity.description, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tim Moderator Komunitas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('${currentCommunity.moderators.length} Moderator Aktif', style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...currentCommunity.moderators.map((mod) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text(mod.name[0])),
                      title: Text(mod.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('${mod.role} • ${mod.studentBatch}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(mod.badge, style: TextStyle(fontSize: 11, color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
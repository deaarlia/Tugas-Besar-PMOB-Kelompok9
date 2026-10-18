String timeAgo(DateTime t) {
  final Duration d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'Baru saja';
  if (d.inMinutes < 60) return '${d.inMinutes} menit yang lalu';
  if (d.inHours < 24) return '${d.inHours} jam yang lalu';
  if (d.inDays == 1) return 'Kemarin';
  return '${d.inDays} hari yang lalu';
}
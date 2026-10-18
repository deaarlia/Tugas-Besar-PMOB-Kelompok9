/// Model data utama aplikasi.
/// Boleh diganti nama class & field-nya sesuai aplikasi kelompok
/// (misalnya Produk, Buku, Kegiatan, Lapangan).
class Item {
 final String id;
 final String title;
 final String subtitle;
 final String description;
 const Item({
 required this.id,
 required this.title,
 required this.subtitle,
 required this.description,
 });
}
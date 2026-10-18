enum ThreadSort {
  newest('Terbaru'),
  popular('Terpopuler'),
  unanswered('Belum Terjawab');

  const ThreadSort(this.label);
  final String label;
}
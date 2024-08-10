
String formatRupiahManual(int amount) {
  String result = amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  return "Rp $result,00";
}

String formatTanggalManual(DateTime date) {
  final months = [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember"
  ];

  String day = date.day.toString();
  String month = months[date.month - 1];
  String year = date.year.toString();

  return "$day $month $year";
}
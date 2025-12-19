class SesiModel {
  final int idSesi;
  final int idPertemuan;
  final String nipDosen;
  final DateTime waktuBuka;
  final DateTime? waktuTutup;
  final String statusSesi;
  final int durasiMenit;
  final double? lokasiLat;
  final double? lokasiLong;
  final int? radiusMeter;
  final String? kodeSesi;
  final String? namaKelas;
  final String? namaMatakuliah;
  final int? pertemuanKe;
  final String? topik;

  SesiModel({
    required this.idSesi,
    required this.idPertemuan,
    required this.nipDosen,
    required this.waktuBuka,
    this.waktuTutup,
    required this.statusSesi,
    required this.durasiMenit,
    this.lokasiLat,
    this.lokasiLong,
    this.radiusMeter,
    this.kodeSesi,
    this.namaKelas,
    this.namaMatakuliah,
    this.pertemuanKe,
    this.topik,
  });

  factory SesiModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;

      final String dateStr = value.toString().trim();

      try {
        // Try ISO format first: "2025-12-07T21:51:09"
        return DateTime.parse(dateStr);
      } catch (e) {
        try {
          // Try MySQL format: "2025-12-07 21:51:09"
          return DateTime.parse(dateStr.replaceFirst(' ', 'T'));
        } catch (e2) {
          print('Error parsing date: $dateStr - $e2');
          return null;
        }
      }
    }

    return SesiModel(
      idSesi: json['id_sesi'] ?? 0,
      idPertemuan: json['id_pertemuan'] ?? 0,
      nipDosen: json['nip_dosen'] ?? '',
      waktuBuka: parseDateTime(json['waktu_buka']) ?? DateTime.now(),
      waktuTutup: parseDateTime(json['waktu_tutup']),
      statusSesi: json['status_sesi'] ?? 'aktif',
      durasiMenit: json['durasi_menit'] ?? 15,
      lokasiLat: json['lokasi_lat'] != null
          ? double.parse(json['lokasi_lat'].toString())
          : null,
      lokasiLong: json['lokasi_long'] != null
          ? double.parse(json['lokasi_long'].toString())
          : null,
      radiusMeter: json['radius_meter'],
      kodeSesi: json['kode_sesi'],
      namaKelas: json['nama_kelas'],
      namaMatakuliah: json['nama_matakuliah'],
      pertemuanKe: json['pertemuan_ke'],
      topik: json['topik'],
    );
  }

  bool get isActive => statusSesi == 'aktif';

  int get sisaMenit {
    final now = DateTime.now();
    final elapsed = now.difference(waktuBuka).inMinutes;
    return durasiMenit - elapsed;
  }

  bool get isExpired => sisaMenit <= 0;
}

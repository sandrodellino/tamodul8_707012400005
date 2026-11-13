import 'package:flutter/material.dart';

enum StatusSiaga { aman, waspada, siaga }

extension StatusSiagaInfo on StatusSiaga {
  String get label {
    switch (this) {
      case StatusSiaga.aman:
        return 'Aman';
      case StatusSiaga.waspada:
        return 'Waspada';
      case StatusSiaga.siaga:
        return 'Siaga';
    }
  }

  Color get warna {
    switch (this) {
      case StatusSiaga.aman:
        return Colors.green;
      case StatusSiaga.waspada:
        return Colors.orange;
      case StatusSiaga.siaga:
        return Colors.red;
    }
  }

  IconData get ikon {
    switch (this) {
      case StatusSiaga.aman:
        return Icons.check_circle;
      case StatusSiaga.waspada:
        return Icons.warning_amber;
      case StatusSiaga.siaga:
        return Icons.error;
    }
  }
}

// Ambang batas simulasi untuk praktikum (bukan standar resmi BPBD).
StatusSiaga hitungStatus(String jenisSensor, double nilai) {
  switch (jenisSensor) {
    case 'ketinggian_air': // cm
      if (nilai >= 250) return StatusSiaga.siaga;
      if (nilai >= 150) return StatusSiaga.waspada;
      return StatusSiaga.aman;
    case 'pergeseran_tanah': // mm
      if (nilai >= 15) return StatusSiaga.siaga;
      if (nilai >= 5) return StatusSiaga.waspada;
      return StatusSiaga.aman;
    case 'curah_hujan': // mm/jam
      if (nilai >= 50) return StatusSiaga.siaga;
      if (nilai >= 20) return StatusSiaga.waspada;
      return StatusSiaga.aman;
    default:
      return StatusSiaga.aman;
  }
}

StatusSiaga statusTertinggi(Iterable<StatusSiaga> daftar) {
  return daftar.fold(
    StatusSiaga.aman,
    (tertinggi, s) => s.index > tertinggi.index ? s : tertinggi,
  );
}

String labelJenis(String jenisSensor) {
  switch (jenisSensor) {
    case 'ketinggian_air':
      return 'Ketinggian Air';
    case 'pergeseran_tanah':
      return 'Pergeseran Tanah';
    case 'curah_hujan':
      return 'Curah Hujan';
    default:
      return jenisSensor;
  }
}

String satuanJenis(String jenisSensor) {
  switch (jenisSensor) {
    case 'ketinggian_air':
      return 'cm';
    case 'pergeseran_tanah':
      return 'mm';
    case 'curah_hujan':
      return 'mm/jam';
    default:
      return '';
  }
}

IconData ikonJenis(String jenisSensor) {
  switch (jenisSensor) {
    case 'ketinggian_air':
      return Icons.water;
    case 'pergeseran_tanah':
      return Icons.terrain;
    case 'curah_hujan':
      return Icons.cloud;
    default:
      return Icons.sensors;
  }
}

String formatWaktu(String waktuIso) {
  final teks = waktuIso.replaceFirst('T', ' ');
  return teks.length > 19 ? teks.substring(0, 19) : teks;
}

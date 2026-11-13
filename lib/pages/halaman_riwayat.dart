import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../utils/status_siaga.dart';
import '../widgets/status_badge.dart';

class HalamanRiwayat extends StatefulWidget {
  const HalamanRiwayat({super.key});

  @override
  State<HalamanRiwayat> createState() => _HalamanRiwayatState();
}

class _HalamanRiwayatState extends State<HalamanRiwayat> {
  late Future<List<PembacaanSensor>> _daftarPembacaan;
  late Future<Map<String, PembacaanSensor>> _terbaruPerJenis;

  @override
  void initState() {
    super.initState();
    _ambilData();
  }

  void _ambilData() {
    _daftarPembacaan = DatabaseHelper.instance.ambilSemuaPembacaan();
    _terbaruPerJenis = DatabaseHelper.instance.ambilPembacaanTerbaruPerJenis();
  }

  void _muatUlangData() {
    setState(_ambilData);
  }

  // UPDATE: koreksi nilai satu pembacaan
  Future<void> _koreksiNilai(PembacaanSensor pembacaan) async {
    final id = pembacaan.id;
    if (id == null) return;
    final controller = TextEditingController(
      text: pembacaan.nilai.toStringAsFixed(1),
    );
    final nilaiBaru = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Koreksi Nilai Pembacaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${labelJenis(pembacaan.jenisSensor)} • '
                '${pembacaan.lokasiPos}'),
            Text(formatWaktu(pembacaan.waktu)),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Nilai (${satuanJenis(pembacaan.jenisSensor)})',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              double.tryParse(controller.text.replaceAll(',', '.')),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (nilaiBaru == null || nilaiBaru < 0) return;
    await DatabaseHelper.instance.ubahNilaiPembacaan(id, nilaiBaru);
    if (!mounted) return;
    _muatUlangData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nilai pembacaan berhasil dikoreksi.')),
    );
  }

  // Indikator status siaga dari data SQLite (pembacaan terbaru per jenis)
  PreferredSizeWidget _indikatorStatus() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(44),
      child: FutureBuilder<Map<String, PembacaanSensor>>(
        future: _terbaruPerJenis,
        builder: (_, snapshot) {
          final terbaru = snapshot.data ?? {};
          if (terbaru.isEmpty) return const SizedBox(height: 44);
          return SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final p in terbaru.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: StatusBadge(
                      status: hitungStatus(p.jenisSensor, p.nilai),
                      teks: '${labelJenis(p.jenisSensor)}: '
                          '${hitungStatus(p.jenisSensor, p.nilai).label}',
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusKeseluruhan() {
    return FutureBuilder<Map<String, PembacaanSensor>>(
      future: _terbaruPerJenis,
      builder: (_, snapshot) {
        final terbaru = snapshot.data ?? {};
        if (terbaru.isEmpty) return const SizedBox.shrink();
        final status = statusTertinggi(
          terbaru.values.map((p) => hitungStatus(p.jenisSensor, p.nilai)),
        );
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(child: StatusBadge(status: status)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Sensor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
            onPressed: _muatUlangData,
          ),
          _statusKeseluruhan(),
        ],
        bottom: _indikatorStatus(),
      ),
      body: FutureBuilder<List<PembacaanSensor>>(
        future: _daftarPembacaan,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal membaca database:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final daftar = snapshot.data ?? [];
          if (daftar.isEmpty) {
            return const Center(
              child: Text('Belum ada pembacaan sensor tersimpan.'),
            );
          }
          return ListView.builder(
            itemCount: daftar.length,
            itemBuilder: (_, index) {
              final pembacaan = daftar[index];
              final status =
                  hitungStatus(pembacaan.jenisSensor, pembacaan.nilai);
              // DELETE: geser ke kiri untuk menghapus satu baris
              return Dismissible(
                key: ValueKey(pembacaan.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  setState(() {
                    daftar.removeAt(index);
                  });
                  final id = pembacaan.id;
                  if (id != null) {
                    await DatabaseHelper.instance.hapusPembacaan(id);
                  }
                  if (!mounted) return;
                  _muatUlangData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pembacaan dihapus.')),
                  );
                },
                child: ListTile(
                  leading: Icon(
                    ikonJenis(pembacaan.jenisSensor),
                    color: status.warna,
                  ),
                  title: Text(
                    '${labelJenis(pembacaan.jenisSensor)}: '
                    '${pembacaan.nilai.toStringAsFixed(1)} '
                    '${satuanJenis(pembacaan.jenisSensor)}',
                  ),
                  subtitle: Text(
                    '${pembacaan.lokasiPos}\n${formatWaktu(pembacaan.waktu)}',
                  ),
                  isThreeLine: true,
                  trailing: StatusBadge(status: status),
                  onTap: () => _koreksiNilai(pembacaan),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

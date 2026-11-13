import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../db/database_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../models/sensor.dart';

class SensorState {
  final Map<String, double> nilaiTerkini;
  final bool simulasiAktif;
  final int jumlahTercatat;

  const SensorState({
    this.nilaiTerkini = const {},
    this.simulasiAktif = false,
    this.jumlahTercatat = 0,
  });

  SensorState copyWith({
    Map<String, double>? nilaiTerkini,
    bool? simulasiAktif,
    int? jumlahTercatat,
  }) {
    return SensorState(
      nilaiTerkini: nilaiTerkini ?? this.nilaiTerkini,
      simulasiAktif: simulasiAktif ?? this.simulasiAktif,
      jumlahTercatat: jumlahTercatat ?? this.jumlahTercatat,
    );
  }
}

class SensorCubit extends Cubit<SensorState> {
  SensorCubit() : super(const SensorState());

  final _random = Random();
  Timer? _timer;

  Future<void> catatPembacaan(Sensor sensor, double nilai) async {
    // 1) Alur pemantauan langsung tetap seperti semula (state sementara).
    final nilaiBaru = Map<String, double>.from(state.nilaiTerkini);
    nilaiBaru[sensor.id] = nilai;
    emit(state.copyWith(nilaiTerkini: nilaiBaru));

    // 2) Tambahan: setiap pembacaan disimpan permanen ke SQLite.
    await DatabaseHelper.instance.tambahPembacaan(
      PembacaanSensor(
        jenisSensor: sensor.jenis,
        nilai: nilai,
        lokasiPos: sensor.lokasiPos,
        waktu: DateTime.now().toIso8601String(),
      ),
    );
    if (isClosed) return;
    emit(state.copyWith(jumlahTercatat: state.jumlahTercatat + 1));
  }

  Future<void> simulasiSekali() async {
    for (final sensor in daftarSensor) {
      await catatPembacaan(sensor, _nilaiAcak(sensor.jenis));
    }
  }

  void toggleSimulasi() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      emit(state.copyWith(simulasiAktif: false));
    } else {
      _timer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => simulasiSekali(),
      );
      emit(state.copyWith(simulasiAktif: true));
    }
  }

  double _nilaiAcak(String jenis) {
    double nilai;
    switch (jenis) {
      case 'ketinggian_air':
        nilai = 80 + _random.nextDouble() * 220; // 80 - 300 cm
        break;
      case 'pergeseran_tanah':
        nilai = _random.nextDouble() * 20; // 0 - 20 mm
        break;
      case 'curah_hujan':
        nilai = _random.nextDouble() * 70; // 0 - 70 mm/jam
        break;
      default:
        nilai = 0;
    }
    return double.parse(nilai.toStringAsFixed(1));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

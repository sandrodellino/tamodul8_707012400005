import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/sensor_cubit.dart';
import '../models/sensor.dart';
import '../widgets/monitor_summary_bar.dart';
import '../widgets/sensor_card.dart';
import '../widgets/theme_toggle_button.dart';

class HalamanDashboard extends StatelessWidget {
  const HalamanDashboard({super.key});

  Future<void> _inputManual(BuildContext context, Sensor sensor) async {
    final controller = TextEditingController();
    final nilai = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Input Manual - ${sensor.nama}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Nilai (${sensor.satuan})',
            helperText: sensor.lokasiPos,
          ),
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

    if (nilai == null || nilai < 0 || !context.mounted) return;
    await context.read<SensorCubit>().catatPembacaan(sensor, nilai);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pembacaan ${sensor.lokasiPos} tersimpan.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Sensor'),
        actions: const [ThemeToggleButton()],
      ),
      body: BlocBuilder<SensorCubit, SensorState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: daftarSensor.length,
                  itemBuilder: (context, index) {
                    final sensor = daftarSensor[index];
                    return SensorCard(
                      sensor: sensor,
                      nilai: state.nilaiTerkini[sensor.id],
                      onInputManual: () => _inputManual(context, sensor),
                    );
                  },
                ),
              ),
              MonitorSummaryBar(
                jumlahTercatat: state.jumlahTercatat,
                simulasiAktif: state.simulasiAktif,
                onSimulasiSekali: () =>
                    context.read<SensorCubit>().simulasiSekali(),
                onToggleSimulasi: () =>
                    context.read<SensorCubit>().toggleSimulasi(),
              ),
            ],
          );
        },
      ),
    );
  }
}

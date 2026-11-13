import 'package:flutter/material.dart';
import 'primary_button.dart';

class MonitorSummaryBar extends StatelessWidget {
  final int jumlahTercatat;
  final bool simulasiAktif;
  final VoidCallback onSimulasiSekali;
  final VoidCallback onToggleSimulasi;

  const MonitorSummaryBar({
    super.key,
    required this.jumlahTercatat,
    required this.simulasiAktif,
    required this.onSimulasiSekali,
    required this.onToggleSimulasi,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$jumlahTercatat pembacaan tersimpan sesi ini',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Simulasi',
                  icon: Icons.sensors,
                  onPressed: onSimulasiSekali,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PrimaryButton(
                  label: simulasiAktif ? 'Hentikan' : 'Otomatis',
                  icon: simulasiAktif
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline,
                  onPressed: onToggleSimulasi,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

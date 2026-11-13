import 'package:flutter/material.dart';
import '../models/sensor.dart';
import '../utils/status_siaga.dart';
import 'status_badge.dart';

class SensorCard extends StatelessWidget {
  final Sensor sensor;
  final double? nilai;
  final VoidCallback onInputManual;

  const SensorCard({
    super.key,
    required this.sensor,
    required this.nilai,
    required this.onInputManual,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nilaiSaatIni = nilai;
    final status =
        nilaiSaatIni == null ? null : hitungStatus(sensor.jenis, nilaiSaatIni);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            ikonJenis(sensor.jenis),
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(sensor.nama, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sensor.lokasiPos),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  nilaiSaatIni == null
                      ? 'Belum ada data'
                      : '${nilaiSaatIni.toStringAsFixed(1)} ${sensor.satuan}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (status != null) ...[
                  const SizedBox(width: 8),
                  StatusBadge(status: status),
                ],
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(Icons.edit_note, color: theme.colorScheme.primary),
          tooltip: 'Input manual',
          onPressed: onInputManual,
        ),
      ),
    );
  }
}

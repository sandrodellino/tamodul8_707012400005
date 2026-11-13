import 'package:flutter/material.dart';
import '../utils/status_siaga.dart';

class StatusBadge extends StatelessWidget {
  final StatusSiaga status;
  final String? teks;

  const StatusBadge({super.key, required this.status, this.teks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.warna.withAlpha(40),
        border: Border.all(color: status.warna),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.ikon, size: 14, color: status.warna),
          const SizedBox(width: 4),
          Text(
            teks ?? status.label,
            style: TextStyle(
              color: status.warna,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/sensor_cubit.dart';
import 'db/web_db_setup.dart'
    if (dart.library.js_interop) 'db/web_db_setup_web.dart';
import 'cubit/theme_cubit.dart';
import 'pages/halaman_dashboard.dart';
import 'pages/halaman_riwayat.dart';
import 'theme/app_theme.dart';

void main() {
  siapkanDatabaseWeb();
  runApp(const AiotPeringatanDiniApp());
}

class AiotPeringatanDiniApp extends StatelessWidget {
  const AiotPeringatanDiniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SensorCubit()),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'AIoT Peringatan Dini',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const KerangkaUtama(),
          );
        },
      ),
    );
  }
}

class KerangkaUtama extends StatefulWidget {
  const KerangkaUtama({super.key});

  @override
  State<KerangkaUtama> createState() => _KerangkaUtamaState();
}

class _KerangkaUtamaState extends State<KerangkaUtama> {
  int _indeks = 0;
  final _halaman = const [HalamanDashboard(), HalamanRiwayat()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _halaman[_indeks],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indeks,
        onDestinationSelected: (i) => setState(() => _indeks = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.sensors), label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.history), label: 'Riwayat Sensor'),
        ],
      ),
    );
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'
    show databaseFactoryFfiWeb;

// Versi web (Chrome): sqflite bawaan tidak mendukung web,
// sehingga dipakai SQLite versi WebAssembly (data tersimpan di IndexedDB).
void siapkanDatabaseWeb() {
  databaseFactory = databaseFactoryFfiWeb;
}

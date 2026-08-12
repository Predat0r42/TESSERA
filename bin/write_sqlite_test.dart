import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

void main(List<String> args) {
  if (args.length < 4) {
    print('Usage: dart run bin/write_sqlite_test.dart <path-to-db> <moduleId> <key> <value>');
    exit(2);
  }
  final path = args[0];
  final moduleId = args[1];
  final key = args[2];
  final value = args[3];
  final file = File(path);
  if (!file.existsSync()) {
    print('DB file not found: $path');
    exit(1);
  }

  final db = sqlite3.open(path);
  try {
    db.execute('INSERT OR REPLACE INTO module_storage_entries(module_id, key, value) VALUES(?, ?, ?)', [moduleId, key, value]);
    print('Inserted: $moduleId | $key -> $value');
  } finally {
    db.dispose();
  }
}

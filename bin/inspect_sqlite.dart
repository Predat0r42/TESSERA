import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart run bin/inspect_sqlite.dart <path-to-db>');
    exit(2);
  }
  final path = args[0];
  final file = File(path);
  if (!file.existsSync()) {
    print('DB file not found: $path');
    exit(1);
  }

  final db = sqlite3.open(path);
  try {
    final ResultSet rs = db.select('SELECT module_id, key, value FROM module_storage_entries');
    if (rs.isEmpty) {
      print('No rows in module_storage_entries.');
      return;
    }
    print('Entries:');
    for (final row in rs) {
      final moduleId = row['module_id'];
      final key = row['key'];
      final value = row['value'];
      print('  $moduleId | $key -> $value');
    }
  } finally {
    db.dispose();
  }
}

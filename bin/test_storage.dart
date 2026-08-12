import 'package:tessera/storage/module_storage.dart';

Future<void> main() async {
  final db = AppDatabase();
  print('Setting value...');
  await db.setValue('test-module', 'counter', 42);
  print('Reading value...');
  final v = await db.getValue('test-module', 'counter');
  print('getValue -> $v');
  final all = await db.getAllForModule('test-module');
  print('getAllForModule -> $all');
}

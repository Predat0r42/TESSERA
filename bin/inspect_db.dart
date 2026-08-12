import 'package:tessera/storage/module_storage.dart';

Future<void> main() async {
  final db = AppDatabase();
  // ignore: avoid_print
  print('Inspecting DB for module "stopwatch"...');
  final all = await db.getAllForModule('stopwatch');
  // ignore: avoid_print
  print('Entries for stopwatch:');
  all.forEach((k, v) => print('  $k -> $v'));
}

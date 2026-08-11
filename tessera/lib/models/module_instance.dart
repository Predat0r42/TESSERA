import '../bridge/lua_state.dart';

/// Загруженный и инициализированный модуль — обёртка над его
/// интерпретатором и метаданными. Не важно, встроенный он или
/// пользовательский: с этого момента разницы между ними нет.
class ModuleInstance {
  final String id;
  final LuaState lua;
  final dynamic moduleTable; // то, что Lua-файл вернул через `return M`

  ModuleInstance({
    required this.id,
    required this.lua,
    required this.moduleTable,
  });

  /// Вызывает M.ui(state) и получает UI-дерево для рендера.
  dynamic buildUi() => lua.callField(moduleTable, 'ui');

  void dispose() => lua.dispose();
}

import 'package:tessera/bridge/bridge_functions.dart';
import 'package:tessera/bridge/lua_state.dart';
import 'package:tessera/event/event_bus.dart';

Future<void> main() async {
  final lua = LuaState.create();
  registerBridge(lua, 'test-module');

  lua.doString("""
    local x = time.now()
    assert(type(x) == 'number')
    local y = time.test()
    assert(y == 42)
  """);

  lua.doString("""
    ui_element = ui.button('Tap', function()
      print('button callback')
    end)
  """);

  final fromLua = lua.getGlobal('ui_element');
  print('UI element from Lua: $fromLua');

  lua.doString("""
    event.on('demo', function()
      print('callback fired')
    end)
  """);

  EventBus.instance.emit('demo');
}

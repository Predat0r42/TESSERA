import 'dart:async';
import 'package:flutter/material.dart';

import '../event/event_bus.dart';
import '../loader/module_loader.dart';
import '../models/module_instance.dart';
import '../renderer/element_renderer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _loader = ModuleLoader();
  final _registry = ModuleRegistry();
  late final ElementRenderer _renderer;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _renderer = ElementRenderer(callLua: _callLua);
    EventBus.instance.on('notify.show', _onNotify);
    _bootstrap();
  }

  // Пока нет flutter_local_notifications — показываем как SnackBar,
  // чтобы можно было проверять логику модулей уже сейчас.
  void _onNotify(dynamic data) {
    if (!mounted) return;
    final title = data['title'] ?? '';
    final body = data['body'] ?? '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title — $body')),
    );
  }

  // Renderer не знает, какому модулю принадлежит колбэк — ищем модуль,
  // которому принадлежит этот LuaState, и вызываем через него.
  // TODO: заменить на прямой вызов через LuaState конкретного модуля,
  // когда появится реальный биндинг (сейчас — заглушка).
  void _callLua(dynamic luaFunctionRef, [List<dynamic> args = const []]) {
    for (final m in _registry.all) {
      try {
        m.lua.callField(luaFunctionRef, '', args);
        setState(() {});
        return;
      } catch (_) {
        continue;
      }
    }
  }

  Future<void> _bootstrap() async {
    // Пока в assets только эталонные модули: часы, секундомер, таймер.
    for (final id in ['clock', 'stopwatch', 'timer']) {
      final module = await _loader.loadBuiltin(id);
      _registry.register(module);
    }
    setState(() {});

    // Общий системный тик — рассылается в шину, модули сами решают,
    // подписываться на него через event.on("time.tick", ...) или нет.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      EventBus.instance.emit('time.tick');
      setState(() {}); // перестроить UI модулей после тика
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    EventBus.instance.off('notify.show', _onNotify);
    for (final m in _registry.all) {
      m.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modules = _registry.all;
    return Scaffold(
      appBar: AppBar(title: const Text('TESSERA')),
      body: modules.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: modules
                  .map<Widget>((ModuleInstance m) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _renderer.render(m.buildUi()),
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}

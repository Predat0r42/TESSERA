import 'package:flutter/material.dart';

/// Функция, которая умеет вызвать Lua-функцию по ссылке, полученной
/// в UI-дереве (например, значение поля 'onTap'). Передаётся снаружи,
/// потому что вызов Lua завязан на конкретный LuaState конкретного
/// модуля — сам Renderer об этом ничего не знает.
typedef LuaCallback = void Function(dynamic luaFunctionRef, [List<dynamic> args]);

/// Превращает Map-дерево, которое вернул ui.* из Lua-модуля,
/// в настоящие Flutter-виджеты. Расширяется по мере добавления
/// новых примитивов в bridge_functions.dart.
class ElementRenderer {
  final LuaCallback callLua;

  // Cache TextEditingControllers so input fields preserve cursor/selection
  // and avoid being recreated on each render.
  final Map<String, TextEditingController> _controllers = {};

  ElementRenderer({required this.callLua});

  Widget render(dynamic element, {String moduleId = '', String path = '0'}) {
    if (element is! Map) return const SizedBox.shrink();

    switch (element['type']) {
      case 'text':
        return Text(
          element['content']?.toString() ?? '',
          style: const TextStyle(fontSize: 24),
        );

      case 'column':
        final children = (element['children'] as List? ?? [])
            .asMap()
            .entries
            .map((e) => render(e.value, moduleId: moduleId, path: '$path.c${e.key}'))
            .toList();
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );

      case 'row':
        final children = (element['children'] as List? ?? [])
            .asMap()
            .entries
            .map((e) => render(e.value, moduleId: moduleId, path: '$path.r${e.key}'))
            .toList();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: children.map((w) => Expanded(child: w)).toList(),
        );

      case 'button':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ElevatedButton(
            onPressed: element['onTap'] == null
                ? null
                : () => callLua(element['onTap']),
            child: Text(element['label']?.toString() ?? ''),
          ),
        );

      case 'input':
        final inputType = element['inputType'] as String? ?? 'text';
        final text = element['value']?.toString() ?? '';
        final key = '${moduleId.isNotEmpty ? moduleId : 'global'}:$path';
        final controller = _controllers.putIfAbsent(key, () => TextEditingController(text: text));
        // Update controller text only when it actually differs to avoid
        // resetting cursor/selection on each render.
        if (controller.text != text) {
          controller.text = text;
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: TextField(
            controller: controller,
            keyboardType:
                inputType == 'number' ? TextInputType.number : TextInputType.text,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            onChanged: (val) {
              if (element['onChanged'] == null) return;
              final parsed = inputType == 'number' ? num.tryParse(val) : val;
              callLua(element['onChanged'], [parsed]);
            },
          ),
        );

      // TODO: 'date'/'time' пикеры внутри 'input' — добавить вместе
      // с модулями Будильник/Календарь, которым они впервые понадобятся.

      default:
        return Text('Неизвестный элемент UI: ${element['type']}');
    }
  }
}

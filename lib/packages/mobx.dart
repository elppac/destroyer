// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'mobx/mobx_counter_store.dart';
import 'package:expressions/expressions.dart';

const String pageId = 'homePage';
const String fieldId = 'root';

class MyEvaluator extends ExpressionEvaluator {
  const MyEvaluator();

  @override
  dynamic evalMemberExpression(
      MemberExpression expression, Map<String, dynamic> context) {
    var object = eval(expression.object, context);
    return object[expression.property.name];
  }
}

expressionEval(String expr, dynamic context) {
  var expression = Expression.parse(expr);
  const evaluator = MyEvaluator();
  var r = evaluator.eval(expression, context);
  return r;
}

class StoreContext with ChangeNotifier {
  final CounterStore _store = CounterStore();
  CounterStore get store => _store;
}

class MobxWrapper extends StatelessWidget {
  const MobxWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => StoreContext(),
      child: const MobxPage(), // 将 Provider 注入到 HomePage 及其子组件
    );
  }
}

class MobxPage extends StatefulWidget {
  const MobxPage({super.key});

  @override
  _MobxPage createState() => _MobxPage();
}

class _MobxPage extends State<MobxPage> {
  Map<String, dynamic> _data = {};
  late bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    String jsonString = await rootBundle.loadString('assets/data.json');
    setState(() {
      _data = jsonDecode(jsonString);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<StoreContext>().store;
    if (store.getField(pageId, fieldId) == null && !isLoading) {
      store.createField(pageId, fieldId, _data);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('MobX Example'),
      ),
      body: isLoading
          ? const CircularProgressIndicator()
          : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FirstMobxComponent(),
                SecondMobxComponent(),
                ExtendMobxComponent(),
                // Observer(builder: (_) {
                //   return Text(
                //       'Page Component: ${context.read<StoreContext>().store.count}');
                // })
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<StoreContext>().store.increment();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// 第一个组件，显示 count 值
class FirstMobxComponent extends StatelessWidget {
  const FirstMobxComponent({super.key});
  @override
  Widget build(BuildContext context) {
    final store = context.read<StoreContext>().store;
    return Center(
      child: Observer(builder: (_) {
        print('count1');
        return Text('First Component: ${store.count}',
            style: const TextStyle(fontSize: 24));
      }),
    );
  }
}

// 第二个组件，也显示 count 值
class SecondMobxComponent extends StatelessWidget {
  const SecondMobxComponent({super.key});
  @override
  Widget build(BuildContext context) {
    final store = context.read<StoreContext>().store;
    return Center(child: Observer(builder: (_) {
      print('count2');
      return Text('Second Component: ${store.count2}',
          style: const TextStyle(fontSize: 24));
    }));
  }
}

class ExtendMobxComponent extends StatefulWidget {
  const ExtendMobxComponent({super.key});

  @override
  _ExtendMobxComponent createState() => _ExtendMobxComponent();
}

class _ExtendMobxComponent extends State<ExtendMobxComponent> {
  final List<ReactionDisposer> _disposers = [];
  @override
  void initState() {
    super.initState();
    final store = context.read<StoreContext>().store;
    _disposers.add(autorun((_) {
      print('autorun age: ${store.data[pageId][fieldId]['age']}');
    }));
  }

  @override
  void dispose() {
    for (final disposer in _disposers) {
      disposer();
    }
    _disposers.clear();
    print('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<StoreContext>().store;
    print('render ExtendMobxComponent');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            const Text('设置值 setField:'),
            IconButton(
              onPressed: () {
                final age = store.data[pageId][fieldId]['age'] - 1;
                store.setField(pageId, fieldId, 'age', age);
              },
              icon: const Icon(Icons.exposure_minus_1),
              iconSize: 20,
            ),
            IconButton(
              onPressed: () {
                final age = store.data[pageId][fieldId]['age'] + 1;
                store.setField(pageId, fieldId, 'age', age);
              },
              icon: const Icon(Icons.exposure_plus_1),
              iconSize: 20,
            ),
            const Text('  updateField:'),
            IconButton(
              onPressed: () {
                final age = store.data[pageId][fieldId]['age'] - 1;
                store.updateField(pageId, fieldId, ['age'], age);
              },
              icon: const Icon(Icons.exposure_minus_1),
              iconSize: 20,
            ),
            IconButton(
              onPressed: () {
                final age = store.data[pageId][fieldId]['age'] + 1;
                store.updateField(pageId, fieldId, ['age'], age);
              },
              icon: const Icon(Icons.exposure_plus_1),
              iconSize: 20,
            )
          ],
        ),
        Row(
          children: [
            Observer(
                builder: (_) => Text(
                      '通过path取数据并响应:  ${store.data[pageId][fieldId]['age']}',
                    ))
          ],
        ),
        Row(
          children: [
            Observer(
                builder: (_) => Text(
                      '通过action取数据并响应:  ${store.getField(pageId, fieldId, 'age')}',
                    ))
          ],
        ),
        Row(
          children: [
            Text(
              '数据类型 string: ${store.getField(pageId, fieldId, 'name')}, ',
            ),
            Text(
              'array: ${store.getField(pageId, fieldId, 'interests')}, ',
            ),
            Text(
              'array[0]: ${store.getField(pageId, fieldId, 'interests')[0]}, ',
            ),
            Text(
              'array[0].key: ${store.getField(pageId, fieldId, 'address')[0]['province']}',
            )
          ],
        ),
        const Divider(
          color: Color.fromARGB(255, 102, 14, 14),
          thickness: 0.5,
          height: 20.0, // 控制分隔线周围的间距
        ),
        const Text(
          'Autorun 查看 print 信息',
          style: TextStyle(color: Color.fromARGB(255, 102, 14, 14)),
        ),
        const Divider(
          color: Color.fromARGB(255, 102, 14, 14),
          thickness: 0.5,
          height: 20.0, // 控制分隔线周围的间距
        ),
        Row(children: [
          Observer(
              builder: (_) => Text(
                      '通过表达式数据响应取已有数据 age: ${expressionEval("ctx.$pageId.$fieldId.age", {
                        "ctx": store.data
                      }).toString()}')),
        ]),
        Row(
          children: [
            Observer(
                builder: (_) => Text(
                        '通过表达式数据响应取不存在的数据 x: ${expressionEval("ctx.$pageId.$fieldId.x", {
                          "ctx": store.data
                        }).toString()}')),
            IconButton(
              onPressed: () {
                final x = (store.data[pageId][fieldId]['x'] ?? 0) + 1;
                store.updateField(pageId, fieldId, ['x'], x);
              },
              icon: const Icon(Icons.exposure_plus_1),
              iconSize: 20,
            )
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Counter with ChangeNotifier {
  int _count = 0;
  int _count2 = 0;

  int get count => _count;
  int get count2 => _count2;

  void increment() {
    _count++;
    notifyListeners();
  }

  void increment2() {
    _count2++;
    notifyListeners();
  }
}

// 第一个组件，显示 count 值
class FirstComponent extends StatelessWidget {
  const FirstComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final count =
        context.select<Counter, int>((value) => value.count); // 监听并获取共享状态

    print('count1');
    return Center(
      child: Text(
        'First Component: $count',
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}

// 第二个组件，也显示 count 值
class SecondComponent extends StatelessWidget {
  const SecondComponent({super.key});

  @override
  Widget build(BuildContext context) {
    int count = context.watch<Counter>().count2; // 监听并获取共享状态

    print('count2');
    return Center(
      child: Text(
        'Second Component: $count',
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}

class ProviderWrapper extends StatelessWidget {
  const ProviderWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Counter(),
      child: const ProviderPage(), // 将 Provider 注入到 HomePage 及其子组件
    );
  }
}

class ProviderPage extends StatelessWidget {
  const ProviderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Example'),
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FirstComponent(),
          SecondComponent(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 调用 Provider 中的 increment 方法
          context.read<Counter>().increment();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

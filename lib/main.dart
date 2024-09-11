import 'package:destroyer/packages/getx.dart';
import 'package:destroyer/packages/mobx.dart';
import 'package:destroyer/packages/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  Provider.debugCheckInvalidValueType = null;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter 状态管理",
      home: const HomeComponent(
        title: 'State Management',
      ), // MyApp 不再处理 Provider
      theme: ThemeData(
        fontFamily: 'PingFang',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
        useMaterial3: true,
      ),
    );
  }
}

class HomeComponent extends StatelessWidget {
  const HomeComponent({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48), // 高度可以自定义
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProviderWrapper(),
                    ),
                  );
                },
                child: const Text('Provider'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48), // 高度可以自定义
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GetXWrapper(),
                    ),
                  );
                },
                child: const Text('GetX'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48), // 高度可以自定义
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MobxWrapper(),
                    ),
                  );
                },
                child: const Text('Mobx'),
              ),
            ],
          ),
        ));
  }
}

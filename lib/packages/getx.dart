// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:destroyer/packages/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const String pageId = 'homePage';
const String fieldId = 'root';
// extension ObservableExtension on dynamic {
//   Rx<dynamic> get obs {
//     if (this is Map) {
//       return this.cast<String, dynamic>().obs;
//     } else if (this is List) {
//       return this.cast<dynamic>().obs;
//     }else if (this.runtimeType == '_JsonMap'){
//       return Map<String, dynamic>.from(this).cast<String, dynamic>().obs;
//     } else {
//       return Rx<dynamic>(this);
//     }
//   }
// }
bool isJsonMap(dynamic data) {
  return data.runtimeType.toString() == '_JsonMap';
}

toRx(dynamic data) {
  if (isJsonMap(data)) {
    return Map<String, dynamic>.from(data).obs;
  }
  return data.obs;
}

class CounterController extends GetxController {
  // 使用 RxInt 来声明可反应式的计数变量
  var count = 0.obs;
  var count2 = 0.obs;

  var data = <String, dynamic>{}.obs;

  // 增加计数的方法
  void increment() {
    count++;
  }

  void increment2() {
    count2++;
  }
  void onInit() {
    final  worker = ever(count, (value) {
      print('counter changed to: $value');
    });
  }

  dynamic getData(String key) {
    return data[key] ?? null;
  }

  setData(String key, dynamic value) {
    data[key] = value;
    // update();
  }

  void createField(String pageId, String fieldId, dynamic fieldData) {
    data[pageId] ??= {};
    data[pageId][fieldId] ??= toRx(fieldData);
  }

  void updateField(
      String pageId, String fieldId, List<String> path, dynamic fieldData) {
    if (data[pageId] != null && data[pageId][fieldId] != null) {
      setValue(data[pageId][fieldId], path, fieldData);
    }
  }

  void setField(
      String pageId, String fieldId, String fieldKey, dynamic fieldData) {
    if (data[pageId] != null && data[pageId][fieldId] != null) {
      data[pageId][fieldId][fieldKey] = fieldData;
    }
  }

  getField(String pageId, String fieldId, [String? key]) {
    if (data[pageId] != null && data[pageId][fieldId] != null) {
      if (key != null) {
        return data[pageId][fieldId][key];
      } else {
        return data[pageId][fieldId];
      }
    } else {
      return null;
    }
  }

  void reset(String pageId) {
    data[pageId] = null;
  }
}

class GetXWrapper extends StatelessWidget {
  const GetXWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return GetXPage();
  }
}

class GetXPage extends StatefulWidget {
  const GetXPage({super.key});

  @override
  _GetXPage createState() => _GetXPage();
}

class _GetXPage extends State<GetXPage> {
  // 在构造函数中创建 GetX 控制器
  final CounterController counterController = Get.put(CounterController());

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
    if (counterController.getField(pageId, fieldId) == null && !isLoading) {
      counterController.createField(pageId, fieldId, _data);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetX Example'),
      ),
      body: isLoading
          ? const CircularProgressIndicator()
          : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FirstMobxComponent(),
                SecondMobxComponent(),
                ExtendMobxComponent(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 调用控制器中的 increment 方法
          counterController.increment();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// 第一个组件，使用 Obx 监听并显示 count 值
class FirstMobxComponent extends StatelessWidget {
  const FirstMobxComponent({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取已存在的控制器
    final CounterController counterController = Get.find();

    return Center(
      child: Obx(() {
        print('count1');
        // Obx 用于监听控制器中的反应式变量
        return Text(
          'First Component: ${counterController.count}',
          style: const TextStyle(fontSize: 24),
        );
      }),
    );
  }
}

// 第二个组件，同样使用 Obx 监听并显示 count 值
class SecondMobxComponent extends StatelessWidget {
  const SecondMobxComponent({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取已存在的控制器
    final CounterController counterController = Get.find();

    return Center(
      child: Obx(() {
        print('count2');
        return Text(
          'Second Component: ${counterController.count2}',
          style: const TextStyle(fontSize: 24),
        );
      }),
    );
  }
}

class ExtendMobxComponent extends StatelessWidget {
  const ExtendMobxComponent({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取已存在的控制器
    final CounterController counterController = Get.find();
    print('render ExtendMobxComponent');


    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            const Text('设置值 setField:'),
            IconButton(
              onPressed: () {
                final age = counterController.data[pageId][fieldId]['age'] - 1;
                counterController.setField(pageId, fieldId, 'age', age);
              },
              icon: Icon(Icons.exposure_minus_1),
              iconSize: 20,
            ),
            IconButton(
              onPressed: () {
                final age = counterController.data[pageId][fieldId]['age'] + 1;
                counterController.setField(pageId, fieldId, 'age', age);
              },
              icon: Icon(Icons.exposure_plus_1),
              iconSize: 20,
            ),
            Text('  updateField:'),
            IconButton(
              onPressed: () {
                final age = counterController.data[pageId][fieldId]['age'] - 1;
                counterController.updateField(pageId, fieldId, ['age'], age);
              },
              icon: Icon(Icons.exposure_minus_1),
              iconSize: 20,
            ),
            IconButton(
              onPressed: () {
                final age = counterController.data[pageId][fieldId]['age'] + 1;
                counterController.updateField(pageId, fieldId, ['age'], age);
              },
              icon: Icon(Icons.exposure_plus_1),
              iconSize: 20,
            )
          ],
        ),
        Row(
          children: [
            Obx(() {
              return Text(
                '通过path取数据并响应:  ${counterController.data[pageId][fieldId]['age']}',
              );
            }),
          ],
        ),
        Row(
          children: [
            Obx(() {
              return Text(
                '通过action取数据并响应:  ${counterController.getField(pageId, fieldId, 'age')}',
              );
            })
          ],
        ),
        Row(
          children: [
            Text(
              '数据类型 string: ${counterController.getField(pageId, fieldId, 'name')}, ',
            ),
            Text(
              'array: ${counterController.getField(pageId, fieldId, 'interests')}, ',
            ),
            Text(
              'array[0]: ${counterController.getField(pageId, fieldId, 'interests')[0]}, ',
            ),
            Text(
              'array[0].key: ${counterController.getField(pageId, fieldId, 'address')[0]['province']}',
            )
          ],
        )
      ],
    );
  }
}

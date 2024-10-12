import 'package:destroyer/components/form_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../components/game_form_component.dart';
import '../components/matrix_form.dart';

class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _Post();
}

class _Post extends State<Post> {
  late List<dynamic>? data;

  @override
  void initState() {
    super.initState();

    Map<String, dynamic> data = {
      'userName': 'test',
      'description': '123',
      'type': '2',
      'orderTime': [10, 18],
      'skillLevel': '1',
      'tags': ['8'],
      'upload': [
        {
          'url':
              'http://127.0.0.1:7001/upload-file/132fcfcc-0e2a-4484-98d8-bf297bae4b30/test.jpeg',
          'fileCode': '132fcfcc-0e2a-4484-98d8-bf297bae4b30',
          'fileName': 'test.jpeg',
          'size': 10000
        }
      ],
      'voice': [
        {
          'url':
              'http://127.0.0.1:7001/upload-file/d0d923ce-6cfb-43cf-a9c2-25fccd150733/voice.mp4',
          'fileCode': 'd0d923ce-6cfb-43cf-a9c2-25fccd150733',
          'fileName': 'voice.mp4',
          'size': 3.602
        }
      ]
    };
    Future.delayed(const Duration(seconds: 1), () {
      useFormStore().setValues(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> formData = [
      {
        "label": "认证图片",
        "name": "images",
        "component": "GameScreenshotUpload",
        "description": "请参照示例正确上传截图"
      },
      {
        "label": "单价",
        "name": "price",
        "component": "GamePrice",
        "options": [
          {"label": "Level 2", "value": "2"},
          {"label": "Level 3", "value": "3"},
        ],
        "description": "技能选择"
      },
      {
        'component': 'TextArea',
        'name': 'description',
        'label': '文字介绍',
        'description': '请围绕该技能，介绍你的服务能力和个人特色吧~',
        'max': 200
      },
      {
        'component': 'OrderTimeRange',
        'name': 'orderTime',
        'label': '处理时间',
      },
      {'component': 'Input', 'name': 'userName', 'label': '用户名', 'max': 20},
      {
        'component': 'Radio.Group',
        'name': 'type',
        'label': '选择分类',
        'description': '请围绕该技能，介绍你的服务能力和个人特色吧~',
        'options': [
          {"label": "L1", "value": "1"},
          {"label": "L2", "value": "2"},
          {"label": "L3", "value": "3"}
        ]
      },
      {
        "label": "技能等级",
        "name": "skillLevel",
        "component": "Select",
        "options": [
          {"label": "Level 1", "value": "1"},
          {"label": "Level 2", "value": "2"},
          {"label": "Level 3", "value": "3"}
        ],
        "description": "技能选择"
      },
      {
        "label": "标签组",
        "name": "tags",
        "component": "Tags",
        "options": [
          {"label": "Level 1 Desc...", "value": "1"},
          {"label": "Level 2", "value": "2"},
          {"label": "Level 3", "value": "3"},
          {"label": "Level 4", "value": "4"},
          {"label": "Level 5", "value": "5"},
          {"label": "Level 6", "value": "6"},
          {"label": "Level 7", "value": "7"},
          {"label": "Level 8", "value": "8"}
        ],
        "description": "技能选择"
      },
      {
        "label": "语音介绍",
        "name": "voice",
        "component": "Voice",
        "description": "请录制一段自我介绍语音，时长5~15s",
        // "min": 5,
        // "max": 15
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Example'),
      ),
      body: SingleChildScrollView(
        child: Provider<MatrixFormContext>(
          create: (_) => MatrixFormContext(
              components: {
                ...FormComponent.components,
                ...GameFormComponent.components
              },
              schema: formData,
              config: {
                'tieredPrice': [
                  {"label": "Level 2", "value": 2},
                  {"label": "Level 3", "value": 3},
                  {"label": "Level 4", "value": 4},
                  {"label": "Level 5", "value": 5},
                  {"label": "Level 6", "value": 6},
                  {"label": "Level 7", "value": 7}
                ],
                'maxPrice': 4,
                'categoryScreenshot': '',
              }),
          builder: (context, child) {
            return Column(children: [
              const MatrixForm(),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                  onPressed: () {
                    MatrixFormContext ctx = context.read<MatrixFormContext>();
                    print(ctx.formInstance.currentState?.validate());
                    if (ctx.formInstance.currentState?.validate() == true) {
                      print('getValues: ${useFormStore().getValues()}');
                    }
                  },
                  child: const Text('Save'))
            ]);
          },
        ),
      ),
      // Form(
      //   child: Column(
      //     children: formData.map((i) {
      //       String componentType = i['component'];
      //       return FormComponent.components[componentType]!(i)(context);
      //     }).toList(),
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

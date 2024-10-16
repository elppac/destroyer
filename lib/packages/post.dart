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
      'price': [2],
      'type': '2',
      'orderTime': [10, 18],
      'skillLevel': '1',
      'tags': ['8'],
      'images': [
        {
          'url':
              'http://192.168.127.138:7001/upload-file/fe5aba7b-25b5-4365-8061-7658406ded7d/3a283bb5-a890-42bf-a523-ba39ba6deafa3369984849552634810.jpg',
          'uid': 'fe5aba7b-25b5-4365-8061-7658406ded7d',
          'name': '3a283bb5-a890-42bf-a523-ba39ba6deafa3369984849552634810.jpg',
          'size': 2792374,
          'width': 3648,
          'height': 2736
        }
      ],
      'voice': [
        {
          'url':
              'http://192.168.127.138:7001/upload-file/da52f7a0-d4f8-481e-a2ed-03f66af91814/voice.mp4',
          'uid': 'da52f7a0-d4f8-481e-a2ed-03f66af91814',
          'name': 'voice.mp4',
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
    return Provider<MatrixFormContext>(
      create: (_) => MatrixFormContext(
          components: {
            ...FormComponent.components,
            ...GameFormComponent.components
          },
          schema: formData,
          config: {
            'tieredPrice': [
              {"label": "Level 2", "value": 2, 'description': "￥0"},
              {"label": "Level 3", "value": 3, 'description': "￥100"},
              {"label": "Level 4", "value": 4, 'description': "￥1000"},
              {"label": "Level 5", "value": 5, 'description': "￥10000"},
              {"label": "Level 6", "value": 6, 'description': "￥100000"},
              {"label": "Level 7", "value": 7, 'description': "￥1000000"}
            ],
            'maxPrice': 4,
            'categoryScreenshot': '',
          }),
      builder: (context, child) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('Post Example'),
            ),
            body: SingleChildScrollView(
              child: Container(child: const MatrixForm()),
            ),
            bottomNavigationBar: Container(
                margin: EdgeInsets.all(16),
                child: TDButton(
                  text: 'Submit',
                  size: TDButtonSize.large,
                  type: TDButtonType.fill,
                  theme: TDButtonTheme.primary,
                  isBlock: true,
                  onTap: () {
                    MatrixFormContext ctx = context.read<MatrixFormContext>();
                    print(ctx.formInstance.currentState?.validate());
                    if (ctx.formInstance.currentState?.validate() == true) {
                      print('getValues: ${useFormStore().getValues()}');
                    }
                  },
                )));
      },
    );
  }
}

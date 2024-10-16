import 'package:destroyer/components/form_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../components/game_form_component.dart';
import '../components/matrix_form.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _Profile();
}

class _Profile extends State<Profile> {
  late List<dynamic>? data;

  @override
  void initState() {
    super.initState();

    Map<String, dynamic> data = {};
    Future.delayed(const Duration(seconds: 1), () {
      useFormStore().setValues(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> formData = [
      {
        'component': 'Gender',
        'name': 'gender',
        'label': '选择分类',
        'description': '请围绕该技能，介绍你的服务能力和个人特色吧~',
        'options': [
          {
            "label": "L1",
            "value": "0",
          },
          {"label": "L2", "value": "1"},
        ]
      },
      {'component': 'DatePicker', 'name': 'birthday', 'label': '生日'},
      {
        'component': 'Input',
        'name': 'nickName',
        'label': '用户名',
        'max': 14,
        'description': '7个字以内，支持中英文和表情符号',
        'rules': [
          {'format': 'NickName', 'max': 14, 'message': '7个字以内，支持中英文'}
        ]
      },
      {
        "label": "头像",
        "name": "avatar",
        "component": "AvatarUpload",
        'description': '请围绕该技能，介绍你的服务能力和个人特色吧~',
        'required': false
      },
    ];

    return Provider<MatrixFormContext>(
      create: (_) => MatrixFormContext(
          components: {
            ...FormComponent.components,
            ...GameFormComponent.components
          },
          schema: formData,
          config: {}),
      builder: (context, child) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('Profile Example'),
            ),
            body: SingleChildScrollView(
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const MatrixForm()),
            ),
            bottomNavigationBar: Container(
                margin: const EdgeInsets.all(16),
                child: TDButton(
                  text: 'Submit',
                  icon: TDIcons.app,
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

import 'package:destroyer/components/form_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../components/matrix_form.dart';

class Post extends StatelessWidget {
  const Post({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> formData = [
      {
        'component': 'Input',
        'name': 'userName',
        'label': '用户名',
        'maxLength': 20
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Example'),
      ),
      body: Provider<MatrixFormContext>(
        create: (_) => MatrixFormContext(
            components: FormComponent.components, schema: formData),
        builder: (context, child) {
          return Column(children: [
            const MatrixForm(),
            TextButton(
                onPressed: () {
                  MatrixFormContext ctx = context.read<MatrixFormContext>();
                  print(ctx.formInstance.currentState);
                },
                child: const Text('Save'))
          ]);
        },
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

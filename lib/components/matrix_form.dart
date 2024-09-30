import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../packages/utils.dart';
import 'form_component.dart';

bool isJsonMap(dynamic data) {
  return data.runtimeType.toString() == '_JsonMap';
}

toRx(dynamic data) {
  if (isJsonMap(data)) {
    return Map<String, dynamic>.from(data).obs;
  }
  return data.obs;
}

class FormStore extends GetxController {
  var data = <String, dynamic>{}.obs;
  setData(String key, dynamic value) {
    data[key] = value;
  }

  void createField(String pageId, String fieldId, dynamic fieldData) {
    data[fieldId] ??= toRx(fieldData);
  }

  void updateField(String fieldId, List<String> path, dynamic fieldData) {
    if (data[fieldId] != null) {
      setIn(data[fieldId], path, fieldData);
    }
  }

  void setField(String fieldId, String fieldKey, dynamic fieldData) {
    if (data[fieldId] != null) {
      data[fieldId][fieldKey] = fieldData;
    }
  }

  getField(String fieldId, [String? key]) {
    if (data[fieldId] != null) {
      if (key != null) {
        return data[fieldId][key];
      } else {
        return data[fieldId];
      }
    } else {
      return null;
    }
  }
}

FormStore useFormStore() {
  return Get.find();
}

class MatrixFormContext with ChangeNotifier {
  final Map<String, FormComponentBuilder> _components;
  final List<Map<String, dynamic>> _schema;
  final GlobalKey<FormState> formInstance = GlobalKey<FormState>();

  MatrixFormContext(
      {required Map<String, FormComponentBuilder> components,
      required List<Map<String, dynamic>> schema})
      : _components = components,
        _schema = schema;

  Map<String, FormComponentBuilder> get components => _components;
  List<Map<String, dynamic>> get schema => _schema;
  // Key get formInstance => _formInstance;
}

class MatrixForm extends StatefulWidget {
  const MatrixForm({super.key});
  @override
  _Form createState() => _Form();
}

class _Form extends State<MatrixForm> {
  // 在构造函数中创建 GetX 控制器
  final FormStore formController = Get.put(FormStore());
  // Map<String, dynamic> _data = {};
  late bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // _loadData();
  }

  @override
  Widget build(BuildContext context) {
    MatrixFormContext ctx = context.read<MatrixFormContext>();
    return Form(
      key: ctx.formInstance,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: ctx.schema.map((i) {
              String componentType = i['component'];
              return ctx.components[componentType]!(i)(context);
            }).toList(),
          ),
          TextButton(
              onPressed: () {
                MatrixFormContext ctx = context.read<MatrixFormContext>();
                print(ctx.formInstance.currentState?.validate());
              },
              child: const Text('Save 2'))
        ],
      ),
    );
  }
}

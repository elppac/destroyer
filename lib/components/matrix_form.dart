import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../packages/utils.dart';
import 'form_component.dart';

bool isJsonMap(dynamic data) {
  String type = data.runtimeType.toString();
  return type == '_JsonMap' ||
      type == 'IdentityMap<String, dynamic>' ||
      type == '_Map<String, dynamic>';
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

  void createField(String fieldId, dynamic fieldData) {
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

  getValues() {
    Map<String, dynamic> values = {};
    data.forEach((key, value) {
      values[key] = value['value'];
    });
    return values;
  }

  setValues(Map<String, dynamic> values) {
    values.forEach((key, value) {
      if (data[key] != null) {
        data[key]['value'] = value;
      }
    });
  }
}

FormStore useFormStore() {
  return Get.find();
}

class MatrixFormContext with ChangeNotifier {
  final Map<String, FormComponentBuilder> _components;
  final List<Map<String, dynamic>> _schema;
  final Map<String, dynamic>? _config;
  final GlobalKey<FormState> formInstance = GlobalKey<FormState>();

  MatrixFormContext(
      {required Map<String, FormComponentBuilder> components,
      required List<Map<String, dynamic>> schema,
      Map<String, dynamic>? config})
      : _components = components,
        _schema = schema,
        _config = config;

  Map<String, FormComponentBuilder> get components => _components;
  List<Map<String, dynamic>> get schema => _schema;
  Map<String, dynamic>? get config => _config;
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
              useFormStore().createField(i['name'], i);
              if (ctx.components[componentType] != null) {
                return ctx.components[componentType]!(i)(context);
              } else {
                return Container(child: Text('未实现的组件 ${componentType}'));
              }
            }).toList(),
          ),
        ],
      ),
    );
  }
}

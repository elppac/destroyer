void setValue(Map<String, dynamic> data, List<String> path, dynamic value) {
  if (path.isEmpty) {
    return; // 路径为空，不做任何操作
  }

  String key = path.first;
  path.removeAt(0);

  if (data[key] == null) {
    if (path.isNotEmpty) {
      // 如果路径还有剩余，创建嵌套对象
      data[key] = {};
    } else {
      // 如果路径已结束，直接赋值
      data[key] = value;
    }
  } else if (path.isEmpty) {
    // 如果路径已结束，直接赋值
    data[key] = value;
  } else {
    // 递归设置子对象的值
    setValue(data[key], path, value);
  }
}

void setIn(Map<String, dynamic> data, List<String> path, dynamic value) =>
    setValue(data, path, value);

T? getValue<T>(Object? object, List<String> path, Map map, {T? defaultValue}) {
  if (object == null) return defaultValue;

  dynamic value = object;
  for (var part in path) {
    if (value is Map && value.containsKey(part)) {
      value = value[part];
    } else {
      return defaultValue;
    }
  }

  return value as T;
}

T? getIn<T>(Object? object, List<String> path, {T? defaultValue}) =>
    getValue(object, path, {defaultValue: defaultValue});

import 'package:mobx/mobx.dart';
import 'package:destroyer/packages/utils.dart';
part 'mobx_counter_store.g.dart';

class CounterStore = _CounterStore with _$CounterStore;
bool isJsonMap(dynamic data) {
  return data.runtimeType.toString() == '_JsonMap';
}
toObservable(dynamic data){
  if (isJsonMap(data)) {
    return ObservableMap.of(Map<String, dynamic>.from(data));
  }else if(data is Map){
    return ObservableMap.of(data);
  }
  return Observable(data);
}

abstract class _CounterStore with Store {
  @observable
  int count = 0;
  @observable
  int count2 = 0;

  @observable
  var data = <String, dynamic>{};

  @action
  void increment() {
    count++;
  }

  @action
  void increment2() {
    count2++;
  }

  void createField(String pageId, String fieldId, dynamic fieldData) {
    data[pageId] ??= {};
    data[pageId][fieldId] ??= toObservable(fieldData);
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
      data[pageId][fieldId][fieldKey] =  fieldData;
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

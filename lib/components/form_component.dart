import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'matrix_field.dart';
import 'matrix_image_picker/matrix_image_picker.dart';
import 'matrix_order_time_range/matrix_order_time_range.dart';
import 'matrix_select/matrix_select.dart';
import 'matrix_tag_picker/matrix_tag_picker.dart';
import 'matrix_voice/matrix_voice.dart';

typedef FormComponentBuilder<T> = WidgetBuilder Function(
  Map<String, dynamic> config,
);

List<TDRadio>? createRadioList(List<Map<String, dynamic>>? data) {
  if (data == null || data.isEmpty) {
    return null;
  }
  return data.map<TDRadio>((item) {
    return TDRadio(
      id: item['value'] as String,
      title: item['label'] as String,
      cardMode: true,
    );
  }).toList();
}

class FormComponent {
  static final Map<String, FormComponentBuilder> components = {
    'Input': (config) => (BuildContext context) {
          var theme = TDTheme.of(context);
          var controller = TextEditingController();
          return withFormField<String>(
            ({onChange, value, errorText}) {
              bool hasError = !(errorText == '' || errorText == null);
              if(controller.text != value){
                controller.text = value ?? '';
              }
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16)
                    .add(const EdgeInsets.only(top: 20.0)),
                child: TDInput(
                    controller: controller,
                    decoration: BoxDecoration(
                        color: theme.whiteColor1,
                        border: Border.all(
                            color:
                                hasError ? theme.errorColor6 : theme.grayColor4,
                            width: 0.5),
                        borderRadius:
                            BorderRadius.circular(theme.radiusDefault)),
                    // additionInfo: errorText ?? '',
                    // additionInfoColor: TDTheme.of(context).errorColor6,
                    hintText: '请输入${config['label']}',
                    leftLabel: config['label'],
                    leftLabelStyle: TextStyle(
                        color:
                            hasError ? theme.errorColor6 : theme.fontGyColor1),
                    maxLength: config['maxLength'],
                    onChanged: onChange,
                    showBottomDivider: false),
              );
            },
            label: config['label'],
            name: config['name'],
            required: true,
          );
        },
    'TextArea': (config) => (BuildContext context) {
          var theme = TDTheme.of(context);
          var controller = TextEditingController();
          return withFormField<String>(
            ({onChange, value, errorText}) {
              bool hasError = !(errorText == '' || errorText == null);
              if(controller.text != value){
                controller.text = value ?? '';
              }
              return TDTextarea(
                  controller: controller,
                  textareaDecoration: BoxDecoration(
                      color: theme.whiteColor1,
                      border: Border.all(
                          color:
                              hasError ? theme.errorColor6 : theme.grayColor4,
                          width: 0.5),
                      borderRadius: BorderRadius.circular(theme.radiusDefault)),
                  additionInfo: errorText ?? '',
                  additionInfoColor: theme.errorColor6,
                  hintText: '请输入${config['label']}',
                  label: config['label'],
                  labelStyle: TextStyle(
                      color: hasError ? theme.errorColor6 : theme.fontGyColor1),
                  layout: TDTextareaLayout.vertical,
                  maxLength: config['max'],
                  indicator: config['max'] != null ? true : false,
                  bordered: true,
                  onChanged: onChange);
            },
            label: config['label'],
            name: config['name'],
            required: true,
          );
        },
    'Radio.Group': (config) => (BuildContext context) {
          return withFormField<String>(
            ({onChange, value, errorText}) {
              var options = createRadioList(config['options']);
              var topLabel = config['label'];
              var theme = TDTheme.of(context);
              bool hasError = !(errorText == '' || errorText == null);
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: topLabel != null,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              topLabel ?? '',
                              style: TextStyle(
                                  color: hasError
                                      ? theme.errorColor6
                                      : theme.fontGyColor1,
                                  fontSize: theme.fontBodyLarge!.size,
                                  height: theme.fontBodyLarge!.height),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                        ],
                      ),
                    ),
                    TDRadioGroup(
                        onRadioGroupChange: (v) {
                          if (onChange != null) {
                            onChange(v ?? '');
                          }
                        },
                        selectId: value,
                        cardMode: true,
                        direction: Axis.horizontal,
                        directionalTdRadios: options)
                  ]);
            },
            label: config['label'],
            name: config['name'],
            required: true,
          );
        },
    'OrderTimeRange': (config) => (BuildContext context) {
          return withFormField<List<int>>(
            ({onChange, value, errorText}) {
              return MatrixOrderTimeRange(
                initialValue: value,
                onChanged: onChange,
                title: config['label'],
                additionInfo: errorText ?? '',
              );
            },
            label: config['label'],
            name: config['name'],
            required: true,
          );
        },
    'Select': (config) => (BuildContext context) {
          return withFormField<dynamic>(
            ({onChange, value, errorText}) {
              return MatrixSelect(
                initialValue: value,
                onChanged: onChange,
                title: config['label'],
                additionInfo: errorText ?? '',
                options: config['options'],
              );
            },
            label: config['label'],
            name: config['name'],
            required: true,
          );
        },
    'Tags': (config) => (BuildContext context) {
          return withFormField<List<dynamic>>(
            ({onChange, value, errorText}) {
              return MatrixTagPicker(
                initialValue: value,
                onChanged: onChange,
                title: config['label'],
                additionInfo: errorText ?? '',
                options: config['options'],
              );
            },
            label: config['label'],
            name: config['name'],
            required: true,
          );
        },
    'Upload': (config) => (BuildContext context) {
          return withFormField<List<dynamic>>(
            ({onChange, value, errorText}) {
              return MatrixImagePicker(
                initialValue: value,
                onChanged: onChange,
                title: config['label'],
                additionInfo: errorText ?? '',
              );
            },
            label: config['label'],
            name: config['name'],
            required: true,
          );
        },
    'Voice': (config) => (BuildContext context) {
          return withFormField<dynamic>(
            ({onChange, value, errorText}) {
              print('component Voice');
              return MatrixVoice(
                initialValue: value,
                onChanged: onChange,
                title: config['label'],
                additionInfo: config['description'],
                error: errorText,
                maxDuration: config['max'] ?? 15.0,
                minDuration: config['min'] ?? 3.0,
              );
            },
            label: config['label'],
            name: config['name'],
            required: true,
          );
        },
  };
}

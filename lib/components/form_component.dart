import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'matrix_field.dart';

typedef FormComponentBuilder<T> = WidgetBuilder Function(
  Map<String, dynamic> config,
);

class FormComponent {
  static final Map<String, FormComponentBuilder> components = {
    'Input': (config) => (BuildContext context) {
          return withFormField<TDInput>(
            (context, onChange) {
              return TDInput(
                leftLabel: config['label'],
                maxLength: config['maxLength'],
                onChanged: onChange,
              );
            },
            label: config['label'],
            name: config['name'],
            required: true,
          );
        }
  };
}

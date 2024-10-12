import 'package:destroyer/components/form_component.dart';
import 'package:flutter/material.dart';

import 'matrix_field.dart';
import 'matrix_image_picker/matrix_image_picker.dart';
import 'matrix_tag_picker/matrix_tag_picker.dart';

class GameFormComponent {
  static final Map<String, FormComponentBuilder> components = {
    'GamePrice': (config) => (BuildContext context) {
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
    'GameScreenshotUpload': (config) => (BuildContext context) {
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
  };
}

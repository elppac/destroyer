import 'package:destroyer/components/matrix_bottom_sheet/show_matrix_bottom_sheet.dart';
import 'package:destroyer/components/matrix_tag_picker/tag_picker.dart';
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

void showMatrixTagPicker(context,
    {required String title,
    required TagPickerCallback? onConfirm,
    TagPickerCallback? onCancel,
    List<dynamic>? initial,
    required List<Map<String, dynamic>> options,
    Duration duration = const Duration(milliseconds: 100),
    double pickerHeight = 200,
    int pickerItemCount = 5,
    bool multiple = false,
    int limit = 9,
    Widget? left,
    Widget? right,
    bool showLeft = true,
    bool showRight = true,
    TDTagSize size = TDTagSize.extraLarge,
    TabPickerCheckValue? checkValue,
    int? crossAxisCount}) {
  var selected = initial ?? [];
  showMatrixBottomSheet(
    context,
    onConfirm: () => onConfirm!(selected),
    title: title,
    showLeft: showLeft,
    showRight: showRight,
    left: left,
    right: right,
    child: TagPicker(
        initialValue: initial,
        options: options,
        checkValue: checkValue,
        onSelected: (v) {
          selected = v;
          if (!multiple) {
            onConfirm!(selected);
          }
        },
        size: size,
        limit: limit,
        multiple: multiple,
        crossAxisCount: crossAxisCount),
  );
}

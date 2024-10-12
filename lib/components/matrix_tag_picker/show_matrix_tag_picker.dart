import 'package:destroyer/components/matrix_tag_picker/tag_picker.dart';
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

void showMatrixTagPicker(context,
    {required String title,
    required TagPickerCallback? onConfirm,
    TagPickerCallback? onCancel,
    List<dynamic>? initial,
    required List<Map<String, dynamic>> options,
    String? rightText,
    String? leftText,
    Duration duration = const Duration(milliseconds: 100),
    double pickerHeight = 200,
    int pickerItemCount = 5,
    bool multiple = false,
    int limit = 9,
    TDTagSize size = TDTagSize.extraLarge}) {
  var selected = initial ?? [];
  Navigator.of(context).push(TDSlidePopupRoute(
      modalBarrierColor: TDTheme.of(context).fontGyColor2,
      slideTransitionFrom: SlideTransitionFrom.bottom,
      builder: (context) {
        return TDPopupBottomConfirmPanel(
            title: title,
            leftClick: () {
              Navigator.maybePop(context);
            },
            rightClick: () {
              onConfirm!(selected);
            },
            child: SizedBox(
                height: pickerHeight,
                child: TagPicker(
                  initialValue: initial,
                  options: options,
                  onSelected: (v) => selected = v,
                  size: size,
                  limit: limit,
                  multiple: multiple,
                ),

            ));
      }));
}

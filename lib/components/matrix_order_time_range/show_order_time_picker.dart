import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'order_time_picker.dart';

void showOrderTimePicker(context,
    {required String title,
    required PickerCallback? onConfirm,
    PickerCallback? onCancel,
    bool useStart = true,
    bool useEnd = true,
    Color? barrierColor,
    int? start,
    int? end,
    List<int>? initial,
    String? rightText,
    String? leftText,
    Duration duration = const Duration(milliseconds: 100),
    double pickerHeight = 200,
    int pickerItemCount = 5}) {
  var now = DateTime.now();
  start ??= 0;
  if (end == null || initial == null) {
    // 如果未指定结束时间，则取当前时间
    end ??= 48;
    initial ??= [now.hour, now.hour + 8];
  }
  showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor:
          barrierColor ?? TDTheme.of(context).fontGyColor2.withOpacity(0.6),
      builder: (context) {
        return OrderTimePicker(
            title: title,
            onConfirm: onConfirm,
            onCancel: onCancel,
            rightText: rightText,
            leftText: leftText,
            model: OrderTimePickerModel(
              useStart: useStart,
              useEnd: useEnd,
              start: start!,
              end: end!,
              initial: initial,
            ),
            pickerHeight: pickerHeight,
            pickerItemCount: pickerItemCount);
      });
}

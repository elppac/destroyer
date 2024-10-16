import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../matrix_select/build_select.dart';

class MatrixDate extends StatefulWidget {
  /// 输入文本变化时回调
  final ValueChanged<dynamic>? onChanged;
  final String title;
  final String? additionInfo;
  final dynamic initialValue;
  const MatrixDate({
    super.key,
    this.initialValue,
    this.onChanged,
    required this.title,
    this.additionInfo,
  });

  @override
  State<StatefulWidget> createState() => _MatrixDate();
}

class _MatrixDate extends State<MatrixDate> {
  late dynamic value = '';

  @override
  void initState() {
    super.initState();
    // 初始化时使用传入的initialValue
    value = widget.initialValue;
  }

  @override
  void didUpdateWidget(MatrixDate oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果initialValue发生变化，则更新value
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        value = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        TDPicker.showDatePicker(context, title: widget.title,
            onConfirm: (selected) {
          setState(() {
            value =
                '${selected['year'].toString().padLeft(4, '0')}-${selected['month'].toString().padLeft(2, '0')}-${selected['day'].toString().padLeft(2, '0')}';
            widget.onChanged!(value);
          });
          Navigator.of(context).pop();
        });
      },
      child: buildSelect(context, value == '' || value == null ? '请选择' : value, widget.title,
          widget.additionInfo),
    );
  }
}

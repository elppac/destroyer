import 'package:flutter/material.dart';
import 'order_time_picker.dart';
import 'show_order_time_picker.dart';
import '../matrix_select/build_select.dart';

class MatrixOrderTimeRange extends StatefulWidget {
  /// 输入文本变化时回调
  final ValueChanged<List<int>>? onChanged;
  final String title;
  final String? additionInfo;
  final List<int>? initialValue;
  const MatrixOrderTimeRange({
    super.key,
    this.onChanged,
    required this.title,
    this.additionInfo,
    this.initialValue,
  });

  @override
  State<StatefulWidget> createState() => _MatrixOrderTimeRange();
}

class _MatrixOrderTimeRange extends State<MatrixOrderTimeRange> {
  late List<int>? value = null;

  @override
  void initState() {
    super.initState();
    // 初始化时使用传入的initialValue
    value = widget.initialValue;
  }

  @override
  void didUpdateWidget(MatrixOrderTimeRange oldWidget) {
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
        showOrderTimePicker(context, title: widget.title,
            onConfirm: (data, selectMap) {
          setState(() {
            value = data;
            widget.onChanged!(data);
          });
          Navigator.of(context).pop();
        }, initial: value);
      },
      child: buildSelect(
          context,
          value == null
              ? '请选择'
              : ((value ?? [])
                  .map((i) => getOrderTimePickerLabel(1, i))
                  .join(' 至 ')),
          widget.title,
          widget.additionInfo),
    );
  }
}

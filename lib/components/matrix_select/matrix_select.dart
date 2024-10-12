import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'build_select.dart';

class MatrixSelect extends StatefulWidget {
  /// 输入文本变化时回调
  final ValueChanged<dynamic>? onChanged;
  final String title;
  final List<Map<String, dynamic>> options;
  final String? additionInfo;
  final dynamic initialValue;
  const MatrixSelect({
    super.key,
    this.initialValue,
    this.onChanged,
    required this.title,
    this.additionInfo,
    required this.options,
  });

  @override
  State<StatefulWidget> createState() => _MatrixSelect();
}

class _MatrixSelect extends State<MatrixSelect> {
  late dynamic value = '';


  @override
  void initState() {
    super.initState();
    // 初始化时使用传入的initialValue
    value = widget.initialValue;
  }

  @override
  void didUpdateWidget(MatrixSelect oldWidget) {
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
    String selectedText = widget.options
        .where((i) => value == i['value'])
        .map((i) => i['label'])
        .join(', ');
    return GestureDetector(
      onTap: () {
        List<int> initialIndexes = widget.options
            .asMap()
            .entries
            .where((i) => value == i.value['value'])
            .map((i) => i.key)
            .toList();
        TDPicker.showMultiPicker(context, title: widget.title,
            onConfirm: (selected) {
          setState(() {
            value = widget.options
                .asMap()
                .entries
                .where((i) => selected.contains(i.key))
                .map((i) => i.value['value'])
                .toList()[0];

            widget.onChanged!(value);
          });
          Navigator.of(context).pop();
        },
            data: [widget.options.map((i) => i['label'] as String).toList()],
            initialIndexes: initialIndexes.isEmpty ? [0] : initialIndexes);
      },
      child: buildSelect(context, selectedText.isEmpty ? '请选择' : selectedText,
          widget.title, widget.additionInfo),
    );
  }
}

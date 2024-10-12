import 'package:destroyer/components/matrix_tag_picker/show_matrix_tag_picker.dart';
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../matrix_select/build_select.dart';

class MatrixTagPicker extends StatefulWidget {
  /// 输入文本变化时回调
  final ValueChanged<List<dynamic>>? onChanged;
  final String title;
  final List<Map<String, dynamic>> options;
  final String? additionInfo;
  final List<dynamic>? initialValue;
  final bool multiple;
  final int limit;
  final TDTagSize size;
  const MatrixTagPicker(
      {super.key,
      this.initialValue,
      this.onChanged,
      required this.title,
      this.additionInfo,
      required this.options,
      this.limit = 9,
      this.size = TDTagSize.extraLarge,
      this.multiple = false});

  @override
  State<StatefulWidget> createState() => _MatrixTagPicker();
}

class _MatrixTagPicker extends State<MatrixTagPicker> {
  late List<dynamic>? value = null;

  @override
  void initState() {
    super.initState();
    // 初始化时使用传入的initialValue
    value = widget.initialValue;
  }

  @override
  void didUpdateWidget(MatrixTagPicker oldWidget) {
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
        showMatrixTagPicker(context, title: widget.title, onConfirm: (data) {
          setState(() {
            value = data;
            widget.onChanged!(data);
          });
          Navigator.of(context).pop();
        }, options: widget.options, initial: widget.initialValue);
      },
      child: buildSelect(
          context,
          (value == null)
              ? '请选择'
              : widget.options
                  .where((i) => value!.contains(i['value']))
                  .map((i) => i['label'])
                  .toList()
                  .join(', '),
          widget.title,
          widget.additionInfo),
    );
  }
}
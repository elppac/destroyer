import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

typedef TagPickerCallback = void Function(List<dynamic> value);

class TagPicker extends StatefulWidget {
  final List<Map<String, dynamic>> options;
  final bool multiple; // 是否允许多选
  final TagPickerCallback? onSelected;
  final List<dynamic>? initialValue;
  final int limit;
  final TDTagSize size;

  const TagPicker(
      {Key? key,
      required this.options,
      this.multiple = true,
      required this.onSelected,
      this.initialValue,
      this.limit = 9,
      this.size = TDTagSize.extraLarge})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TagPickerState();
}

class _TagPickerState extends State<TagPicker> {
  final List<dynamic> _selected = [];

  @override
  void initState() {
    super.initState();
    _selected.addAll(widget.initialValue ?? []);
  }

  void _onTagSelected(dynamic value) {
    setState(() {
      if (widget.multiple) {
        if (_selected.length >= widget.limit) {
          TDToast.showText('最多选择${widget.limit}个', context: context);
          return;
        }
        if (_selected.contains(value)) {
          _selected.remove(value);
        } else {
          _selected.add(value);
        }
      } else {
        if (!_selected.contains(value)) {
          _selected.clear();
          _selected.add(value);
        }
      }
      if (widget.onSelected != null) {
        widget.onSelected!(_selected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20.0,
      runSpacing: 12.0,
      children: widget.options.map((entry) {
        final dynamic index = entry['value'];
        return GestureDetector(
          onTap: () => _onTagSelected(index),
          child: TDTag(
            size: widget.size,
            entry['label'],
            shape: TDTagShape.round,
            backgroundColor:
                _selected.contains(index) ? Colors.black45 : Colors.white,
            textColor:
                _selected.contains(index) ? Colors.white : Colors.black45,
            // style: TDTagStyle(
            //   borderColor:
            //       _selected.contains(index) ? Colors.black26 : Colors.grey,
            // ),
          ),
        );
      }).toList(),
    );
  }
}

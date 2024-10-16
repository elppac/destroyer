import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

typedef TagPickerCallback = void Function(List<dynamic> value);
typedef TabPickerCheckValue = bool Function(List<dynamic> value);

class TagPicker extends StatefulWidget {
  final List<Map<String, dynamic>> options;
  final bool multiple; // 是否允许多选
  final TagPickerCallback? onSelected;
  final List<dynamic>? initialValue;
  final int limit;
  final TDTagSize size;
  final TabPickerCheckValue? checkValue;
  final int? crossAxisCount;

  const TagPicker(
      {Key? key,
      required this.options,
      this.multiple = true,
      required this.onSelected,
      this.initialValue,
      this.crossAxisCount,
      this.limit = 9,
      this.size = TDTagSize.extraLarge,
      this.checkValue})
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
      if (widget.checkValue != null && !widget.checkValue!([value])) {
        return;
      }
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

  Widget item(int index) {
    var theme = TDTheme.of(context);
    var entry = widget.options[index];
    var value = entry['value'];
    return GestureDetector(
      onTap: () => _onTagSelected(value),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.radiusExtraLarge),
            color: _selected.contains(value) ? Colors.black45 : Colors.white,
            border: Border.all(
                color:
                    _selected.contains(index) ? Colors.black26 : Colors.grey)),
        child: Text(
          entry['label'],
          style: TextStyle(
              color: _selected.contains(value) ? Colors.white : Colors.black45),
        ),
      ),
    );
  }

  List<Widget> list() {
    return widget.options.map((entry) {
      var value = entry['value'];
      return GestureDetector(
          onTap: () => _onTagSelected(value),
          child: TDTag(
            size: widget.size,
            entry['label'],
            shape: TDTagShape.round,
            backgroundColor:
                _selected.contains(value) ? Colors.black45 : Colors.white,
            textColor:
                _selected.contains(value) ? Colors.white : Colors.black45,

            // style: TDTagStyle(
            //   borderColor:
            //       _selected.contains(index) ? Colors.black26 : Colors.grey,
            // ),
          ));
    }).toList();
  }

  Widget grid(BuildContext context) {
    var theme = TDTheme.of(context);
    // return GridView.count(
    //   crossAxisCount: 3, // 每行 3 个
    //   crossAxisSpacing: 10, // 横向间距
    //   mainAxisSpacing: 10, // 纵向间距
    //   padding: const EdgeInsets.all(8.0),
    //   children: list());
    return GridView.builder(
      padding: EdgeInsets.all(theme.spacer16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 每行 2 个
        crossAxisSpacing: 8, // 横向间距
        mainAxisSpacing: 8, // 纵向间距
        childAspectRatio: 3, // 控制每个子元素的宽高比
      ),
      itemCount: widget.options.length,
      itemBuilder: (context, index) {
        return item(index);
      },
    );
  }

  Widget wrap(BuildContext context) {
    return Wrap(
      spacing: 20.0,
      runSpacing: 12.0,
      children: list(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.crossAxisCount == null ? wrap(context) : grid(context);
  }
}

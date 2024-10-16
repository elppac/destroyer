import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class MatrixGender<T> extends StatefulWidget {
  final ValueChanged<T> onChanged;
  final String title;
  final String? additionInfo;
  final List<T>? initialValue;
  final List<Map<String, dynamic>> options;
  final String? error;
  final double? optionSize;

  const MatrixGender(
      {super.key,
      required this.onChanged,
      required this.title,
      this.additionInfo,
      this.initialValue,
      this.error,
      required this.options,
      this.optionSize});

  @override
  State<StatefulWidget> createState() => _MatrixGender<T>();
}

class _MatrixGender<T> extends State<MatrixGender> {
  late T? value = null;

  void _onSelected(T v) {
    value = v;
    setState(() {
      widget.onChanged(v);
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    var theme = TDTheme.of(context);
    double? size = widget.optionSize;
    if (size == null) {
      var screenWidth = MediaQuery.of(context).size.width;
      size = (screenWidth / 2 - theme.spacer32 - theme.spacer8);
    }

    List<Widget> options = widget.options.map((i) {
      return GestureDetector(
          onTap: () => _onSelected(i['value']),
          child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 2,
                      color: value == i['value']
                          ? theme.brandColor5
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(theme.radiusExtraLarge)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(theme.radiusExtraLarge),
                  child: Image.network(
                      'http://192.168.127.138:7001/upload-file/05eed256-c45b-41d0-bea9-9dac5346d8f2/test.jpeg'))));
    }).toList();
    return Column(children: [
      Container(
        margin: EdgeInsets.symmetric(horizontal: theme.spacer16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.radiusLarge),
            border: Border.all(
                color: widget.error == null || widget.error == ''
                    ? Colors.transparent
                    : theme.errorColor6)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: options,
        ),
      )
    ]);
  }
}

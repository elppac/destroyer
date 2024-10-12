import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../matrix_voice/matrix_recorder.dart';

class MatrixVoice extends StatefulWidget {
  final ValueChanged<dynamic>? onChanged;
  final String title;
  final String? additionInfo;
  final List<dynamic>? initialValue;
  // final bool multiple;
  final double minDuration;
  final double maxDuration;
  final String? error;

  const MatrixVoice(
      {super.key,
      this.onChanged,
      required this.title,
      this.additionInfo,
      this.initialValue,
      this.minDuration = 3.0,
      this.maxDuration = 15.0,
      this.error});

  @override
  State<StatefulWidget> createState() => _MatrixVoice();
}

class _MatrixVoice extends State<MatrixVoice> {
  late List<dynamic>? value;

  @override
  Widget build(BuildContext context) {
    var theme = TDTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 16,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.title,
                style: TextStyle(
                    color: widget.error == null || widget.error == ''
                        ? theme.fontGyColor1
                        : theme.errorColor6,
                    fontSize: theme.fontBodyLarge!.size,
                    height: theme.fontBodyLarge!.height),
              ),
            ),
            Visibility(
                visible: widget.additionInfo != null,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.additionInfo ?? '',
                      style: TextStyle(color: theme.fontGyColor3),
                    ))),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
        MatrixRecorder(
          maxDuration: widget.maxDuration,
          minDuration: widget.minDuration,
          initialValue: widget.initialValue,
          onChanged: widget.onChanged,
        )
      ],
    );
  }
}

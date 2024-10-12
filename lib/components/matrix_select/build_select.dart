import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

Widget buildSelect(
    BuildContext context, String output, String title, String? error) {
  var theme = TDTheme.of(context);
  return Container(
    decoration: BoxDecoration(
        color: theme.whiteColor1,
        border: Border.all(
            color: error == '' || error == null
                ? Colors.transparent
                : theme.errorColor6,
            width: 0.5),
        borderRadius: BorderRadius.circular(theme.radiusDefault)),
    margin: const EdgeInsets.symmetric(horizontal: 16)
        .add(const EdgeInsets.only(top: 20.0)),
    height: 56,
    child: Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
              child: TDText(
                title,
                font: TDTheme.of(context).fontBodyLarge,
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(right: 16, left: 16),
              child: Row(
                children: [
                  Expanded(
                      child: TDText(
                    output,
                    font: TDTheme.of(context).fontBodyLarge,
                    textColor:
                        TDTheme.of(context).fontGyColor3.withOpacity(0.4),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Icon(
                      TDIcons.chevron_right,
                      color: TDTheme.of(context).fontGyColor3.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ],
    ),
  );
}

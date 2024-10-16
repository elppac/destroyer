import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:tdesign_flutter/src/util/context_extension.dart';

typedef MatrixBottomSheetCallback = void Function();

void showMatrixBottomSheet(context,
    {String? title,
    required MatrixBottomSheetCallback? onConfirm,
    MatrixBottomSheetCallback? onCancel,
    Duration duration = const Duration(milliseconds: 100),
    Color? barrierColor,
    double pickerHeight = 200,
    int pickerItemCount = 5,
    required Widget child,
    Widget? right,
    bool showRight = true,
    Widget? left,
    bool showLeft = true}) {
  var pickerTitleHeight = 56.0;
  double getTitleHeight() => pickerTitleHeight;
  Widget buildTitle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16),
      height: getTitleHeight(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Visibility(
            visible: showLeft,
            child: left ??
                GestureDetector(
                    onTap: () {
                      if (onCancel != null) {
                        onCancel();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: TDText(
                      context.resource.cancel,
                      style: TextStyle(
                          fontSize: TDTheme.of(context).fontBodyLarge!.size,
                          color: TDTheme.of(context).fontGyColor2),
                    )),
          ),
          // 左边按钮

          // 中间title
          Expanded(
            child: title == null
                ? Container()
                : Center(
                    child: TDText(
                      title,
                      style: TextStyle(
                          fontSize: TDTheme.of(context).fontTitleLarge!.size,
                          fontWeight: FontWeight.w600,
                          color: TDTheme.of(context).fontGyColor1),
                    ),
                  ),
          ),

          // 右边按钮
          Visibility(
            visible: showRight,
            child: right ??
                GestureDetector(
                  onTap: () {
                    if (onConfirm != null) {
                      onConfirm!();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: TDText(
                    context.resource.confirm,
                    style: TextStyle(
                        fontSize: TDTheme.of(context).fontBodyLarge!.size,
                        color: TDTheme.of(context).brandNormalColor),
                  ),
                ),
          )
        ],
      ),
    );
  }

  showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor:
          barrierColor ?? TDTheme.of(context).fontGyColor2.withOpacity(0.6),
      builder: (context) {
        var maxWidth = MediaQuery.of(context).size.width;
        return Container(
          width: maxWidth,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: TDTheme.of(context).whiteColor1,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(TDTheme.of(context).radiusExtraLarge),
              topRight: Radius.circular(TDTheme.of(context).radiusExtraLarge),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildTitle(context),
              SizedBox(height: pickerHeight, child: child)
            ],
          ),
        );
      });
}

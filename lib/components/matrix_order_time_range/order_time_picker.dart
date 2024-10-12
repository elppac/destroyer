import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
// ignore: implementation_imports
import 'package:tdesign_flutter/src/components/picker/no_wave_behavior.dart';
// ignore: implementation_imports
import 'package:tdesign_flutter/src/util/context_extension.dart';

typedef PickerCallback = void Function(
    List<int> value, Map<String, int> selected);

getOrderTimePickerLabel(int whichLine, int code) {
  if (whichLine == 1 || whichLine == 2) {
    if (code > 23) {
      return '次日 ${(code % 24).toString().padLeft(2, '0')}:00';
    }
    return '${(code).toString().padLeft(2, '0')}:00';
  } else if (whichLine == 0) {
    return '起始';
  } else if (whichLine == 3) {
    return '截止';
  }
}

/// 时间选择器
class OrderTimePicker extends StatefulWidget {
  const OrderTimePicker(
      {required this.title,
      required this.onConfirm,
      this.rightText,
      this.leftText,
      this.onCancel,
      this.backgroundColor,
      this.titleDividerColor,
      this.topRadius,
      this.titleHeight,
      this.padding,
      this.leftPadding,
      this.rightPadding,
      this.leftTextStyle,
      this.rightTextStyle,
      this.centerTextStyle,
      this.customSelectWidget,
      this.itemDistanceCalculator,
      required this.model,
      this.showTitle = true,
      this.pickerHeight = 200,
      required this.pickerItemCount,
      Key? key})
      : super(key: key);

  /// 选择器标题
  final String title;

  /// 右侧按钮文案
  final String? rightText;

  /// 左侧按钮文案
  final String? leftText;

  /// 选择器确认按钮回调
  final PickerCallback? onConfirm;

  /// 选择器取消按钮回调
  final PickerCallback? onCancel;

  /// 背景颜色
  final Color? backgroundColor;

  /// 标题分割线颜色
  final Color? titleDividerColor;

  /// 顶部圆角
  final double? topRadius;

  /// 标题高度
  final double? titleHeight;

  /// 左边填充
  final double? leftPadding;

  /// 右边填充
  final double? rightPadding;

  /// 根据距离计算字体颜色、透明度、粗细
  final ItemDistanceCalculator? itemDistanceCalculator;

  /// 选择器List的视窗高度，默认200
  final double pickerHeight;

  /// 选择器List视窗中item个数，pickerHeight / pickerItemCount即item高度
  final int pickerItemCount;

  /// 自定义选择框样式
  final Widget? customSelectWidget;

  /// 自定义左侧文案样式
  final TextStyle? leftTextStyle;

  /// 自定义右侧文案样式
  final TextStyle? rightTextStyle;

  /// 自定义中间文案样式
  final TextStyle? centerTextStyle;

  /// 适配padding
  final EdgeInsets? padding;

  /// 是否展示标题
  final bool showTitle;

  /// 数据模型
  final OrderTimePickerModel model;

  @override
  State<StatefulWidget> createState() => _OrderTimePickerState();
}

class _OrderTimePickerState extends State<OrderTimePicker> {
  double pickerHeight = 0;
  static const _pickerTitleHeight = 56.0;

  @override
  void initState() {
    super.initState();
    pickerHeight = widget.pickerHeight;
  }

  bool useAll() {
    if (widget.model.useStart && widget.model.useEnd) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var maxWidth = MediaQuery.of(context).size.width;
    return Container(
      width: maxWidth,
      padding: widget.padding ??
          EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? TDTheme.of(context).whiteColor1,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
              widget.topRadius ?? TDTheme.of(context).radiusExtraLarge),
          topRight: Radius.circular(
              widget.topRadius ?? TDTheme.of(context).radiusExtraLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: widget.showTitle == true,
            child: buildTitle(context),
          ),
          SizedBox(
            height: pickerHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: widget.customSelectWidget ??
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                            color: TDTheme.of(context).grayColor1,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6))),
                      ),
                ),
                Container(
                    height: pickerHeight,
                    width: maxWidth,
                    padding: const EdgeInsets.only(left: 32, right: 32),
                    child: Row(
                      children: [
                        Expanded(child: buildList(context, 0)),
                        widget.model.useStart
                            ? Expanded(
                                child: buildList(context, 1),
                                flex: 2,
                              )
                            : Container(),
                        widget.model.useEnd
                            ? Expanded(child: buildList(context, 2), flex: 2)
                            : Container(),
                        Expanded(child: buildList(context, 3))
                      ],
                    )),
                // 蒙层
                Positioned(
                  top: 0,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      height: _pickerTitleHeight,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                            TDTheme.of(context).whiteColor1,
                            TDTheme.of(context).whiteColor1.withOpacity(0)
                          ])),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      height: _pickerTitleHeight,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                            TDTheme.of(context).whiteColor1,
                            TDTheme.of(context).whiteColor1.withOpacity(0)
                          ])),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildList(context, int whichLine) {
    /// whichLine参数表示这个列表表示的是年，还是月还是日......
    var maxWidth = MediaQuery.of(context).size.width;
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ScrollConfiguration(
          behavior: NoWaveBehavior(),
          child: ListWheelScrollView.useDelegate(
              itemExtent: pickerHeight / widget.pickerItemCount,
              diameterRatio: 100,
              controller: widget.model.controllers[whichLine],
              physics: whichLine == 0 || whichLine == 3
                  ? const NeverScrollableScrollPhysics()
                  : const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                if (whichLine == 1) {
                  // 年月的改变会引起日的改变, 年的改变会引起月的改变
                  setState(() {
                    switch (whichLine) {
                      case 1:
                        widget.model.refreshEndDataAndController();
                        break;
                    }

                    /// 使用动态高度，强制列表组件的state刷新，以展现更新的数据，详见下方链接
                    /// FIX:https://github.com/flutter/flutter/issues/22999
                    pickerHeight =
                        pickerHeight - Random().nextDouble() / 100000000;
                  });
                }
              },
              childDelegate: ListWheelChildBuilderDelegate(
                  childCount: widget.model.data[whichLine].length,
                  builder: (context, index) {
                    return Container(
                        alignment: Alignment.center,
                        height: pickerHeight / widget.pickerItemCount,
                        width: maxWidth,
                        child: [0, 3].contains(whichLine)
                            ? Text(
                                getOrderTimePickerLabel(whichLine,
                                    widget.model.data[whichLine][index]),
                                style: TextStyle(
                                    color: TDTheme.of(context).fontGyColor3))
                            : TDItemWidget(
                                index: index,
                                itemHeight:
                                    pickerHeight / widget.pickerItemCount,
                                content: getOrderTimePickerLabel(whichLine,
                                    widget.model.data[whichLine][index]),
                                fixedExtentScrollController:
                                    widget.model.controllers[whichLine],
                                itemDistanceCalculator:
                                    widget.itemDistanceCalculator,
                              ));
                  })),
        ));
  }

  Widget buildTitle(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: widget.leftPadding ?? 16, right: widget.rightPadding ?? 16),

      /// 减去分割线的空间
      height: getTitleHeight() - 0.5,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// 左边按钮
          GestureDetector(
              onTap: () {
                if (widget.onCancel != null) {
                  var selected = <String, int>{
                    'start': widget.model.useStart
                        ? widget.model.startFixedExtentScrollController
                                .selectedItem +
                            widget.model.data[1][0]
                        : -1,
                    'end': widget.model.useEnd
                        ? widget.model.endFixedExtentScrollController
                                .selectedItem +
                            widget.model.data[2][0]
                        : -1,
                  };
                  widget.onCancel!(
                      [selected['start']!, selected['end']!], selected);
                } else {
                  Navigator.of(context).pop();
                }
              },
              behavior: HitTestBehavior.opaque,
              child: TDText(widget.leftText ?? context.resource.cancel,
                  style: widget.leftTextStyle ??
                      TextStyle(
                          fontSize: TDTheme.of(context).fontBodyLarge!.size,
                          color: TDTheme.of(context).fontGyColor2))),

          /// 中间title
          Expanded(
            child: Center(
              child: TDText(
                widget.title,
                style: widget.centerTextStyle ??
                    TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: TDTheme.of(context).fontGyColor1,
                    ),
              ),
            ),
          ),

          /// 右边按钮
          GestureDetector(
            onTap: () {
              if (widget.onConfirm != null) {
                var selected = <String, int>{
                  'start': widget.model.useStart
                      ? widget.model.startFixedExtentScrollController
                              .selectedItem +
                          widget.model.data[1][0]
                      : -1,
                  'end': widget.model.useEnd
                      ? widget.model.endFixedExtentScrollController
                              .selectedItem +
                          widget.model.data[2][0]
                      : -1,
                };
                widget.onConfirm!(
                    [selected['start']!, selected['end']!], selected);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: TDText(
              widget.rightText ?? context.resource.confirm,
              style: widget.rightTextStyle ??
                  TextStyle(
                      fontSize: TDTheme.of(context).fontBodyLarge!.size,
                      color: TDTheme.of(context).brandNormalColor),
            ),
          ),
        ],
      ),
    );
  }

  double getTitleHeight() => widget.titleHeight ?? _pickerTitleHeight;
}

// 时间选择器的数据类
class OrderTimePickerModel {
  final bool useStart = true;
  final bool useEnd = true;
  late int start;
  late int end;
  List<int>? initial;

  late List<int> initialData;
  var now = DateTime.now();

  /// 这二项随滑动而更新，注意初始化
  late int startIndex;
  late int endIndex;

  late List<List<int>> data = [
    [],
    List.generate(start, (index) => index + start),
    List.generate(end - start, (index) => index + start + 1),
    []
  ];
  late var controllers;
  late FixedExtentScrollController startFixedExtentScrollController;
  late FixedExtentScrollController endFixedExtentScrollController;

  OrderTimePickerModel(
      {required this.start,
      required this.end,
      this.initial,
      required bool useStart,
      required bool useEnd}) {
    setInitialData();
    setInitialStartData();
    setInitialEndData();
    setPrefix();
    setSuffix();
    setControllers();
    addListener();
  }

  void setInitialData() {
    var startData = start;
    var endData = end;
    if (initial != null) {
      initialData = initial!;
      if (initialData[0] < startData) {
        initialData[0] = startData;
      } else if (initialData[1] > endData) {
        initialData[1] = endData;
      }
      return;
    }
    initialData = [startData, endData];
  }

  void setInitialStartData() {
    /// @Test
    // int count =  min(end - start, 24 - now.hour);
    data[1] = List.generate(24, (index) => index);
  }

  void setInitialEndData() {
    /// @Test
    data[2] = List.generate(24, (index) => index + now.hour);
  }

  void setPrefix() {
    data[0] = [-1];
  }

  void setSuffix() {
    data[3] = [-1];
  }

  void setControllers() {
    /// 初始化Index
    startIndex = initialData[0] - data[1][0];
    endIndex = initialData[1] - data[2][0];

    controllers = [
      FixedExtentScrollController(initialItem: -1),
      FixedExtentScrollController(initialItem: startIndex),
      FixedExtentScrollController(initialItem: endIndex),
      FixedExtentScrollController(initialItem: -1),
    ];
    startFixedExtentScrollController = controllers[1];
    endFixedExtentScrollController = controllers[2];
  }

  void addListener() {
    /// 给年月日加上监控
    startFixedExtentScrollController.addListener(() {
      startIndex = startFixedExtentScrollController.selectedItem;
    });
    endFixedExtentScrollController.addListener(() {
      endIndex = endFixedExtentScrollController.selectedItem;
    });
  }

  void refreshEndDataAndController() {
    var selectedStart = startIndex + data[1][0];
    var oldEndValue = data[2][endIndex];
    data[2] = List.generate(24, (index) => index + selectedStart + 1);
    int index = data[2].indexOf(oldEndValue);
    if (index == -1) {
      endFixedExtentScrollController.jumpToItem(0);
    } else {
      endFixedExtentScrollController.jumpToItem(index);
    }
  }

  Map<String, int> getSelectedMap() {
    var map = <String, int>{
      'start': startIndex + data[1][0],
      'end': endIndex + data[2][0],
    };
    return map;
  }
}

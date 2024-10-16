import 'package:destroyer/components/form_component.dart';
import 'package:destroyer/components/matrix_bottom_sheet/show_matrix_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'matrix_field.dart';
import 'matrix_form.dart';
import 'matrix_image_picker/matrix_image_picker.dart';
import 'matrix_tag_picker/matrix_tag_picker.dart';

class GameFormComponent {
  static final Map<String, FormComponentBuilder> components = {
    'GamePrice': (config) => (BuildContext context) {
          MatrixFormContext ctx = context.read<MatrixFormContext>();
          return withFormField<List<dynamic>>(
            ({onChange, value, errorText}) {
              return MatrixTagPicker(
                crossAxisCount: 3,
                initialValue: value,
                onChanged: onChange,
                title: config['label'],
                additionInfo: errorText ?? '',
                options: ctx.config!['tieredPrice'],
                showLeft: false,
                right: GestureDetector(
                    onTap: () {
                      var theme = TDTheme.of(context);
                      renderCell(String text) {
                        return Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(text, textAlign: TextAlign.center));
                      }

                      List<TableRow> tableRows = [
                        TableRow(children: [
                          renderCell('价格阶梯'),
                          renderCell('单价'),
                          renderCell('已完成接单流水')
                        ])
                      ];
                      ctx.config!['tieredPrice'].forEach((item) {
                        tableRows.add(TableRow(
                          children: [
                            renderCell(item['value'].toString()),
                            renderCell(item['label']),
                            renderCell(item['description']),
                          ],
                        ));
                      });
                      showMatrixBottomSheet(
                        title: '单价规则说明',
                        pickerHeight: 500,
                        context,
                        showLeft: false,
                        showRight: false,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                    '在 Flutter 中，const 构造 Widget 是为了优化性能。但如果你需要动态数据，请避免在构造中使用 const。'),
                                const SizedBox(
                                  height: 12,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                      color: theme.grayColor1,
                                      borderRadius: BorderRadius.circular(
                                          theme.radiusDefault)),
                                  child: Table(
                                      columnWidths: const {
                                        0: FlexColumnWidth(1.0),
                                        1: FlexColumnWidth(1.0),
                                        2: FlexColumnWidth(1.5)
                                      },
                                      border: TableBorder.all(
                                          color: theme.grayColor3),
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      children: tableRows),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                const Text(
                                  '这个错误通常会在 Dart 中出现，当你尝试在常量表达式（const）中调用方法或执行运行时计算时。Dart 不允许在常量表达式中调用方法，因为这些操作需要在编译期完成，而方法调用只能在运行时进行。',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onConfirm: () => {},
                      );
                    },
                    child: const Icon(Icons.help_outline)),
                checkValue: (v) {
                  if (v[0] > ctx.config!['maxPrice']) {
                    TDToast.showFail('XXX', context: context);
                    return false;
                  }
                  return true;
                },
              );
            },
            label: config['label'],
            name: config['name'],
            required: true,
          );
        },
    'GameScreenshotUpload': (config) => (BuildContext context) {
          var theme = TDTheme.of(context);
          return withFormField<List<dynamic>>(
            ({onChange, value, errorText}) {
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: theme.spacer16),
                    child: MatrixImagePicker(
                      initialValue: value,
                      onChanged: onChange,
                      title: config['label'],
                      height: constraints.maxWidth * 9 / 19.5,
                      additionInfo: errorText ?? '',
                    ),
                  );
                },
              );
            },
            label: config['label'],
            name: config['name'],
            required: config['required'] ?? true,
          );
        },
  };
}

import 'package:destroyer/components/matrix_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum Direction { column, row }

typedef FormFieldBuilder<T> = Widget Function(
    BuildContext context, ValueChanged<T>? onChange);

typedef MatrixFormFieldBuilder<T> = Widget Function(
    {ValueChanged<T>? onChange, T? value, String? errorText});

class MatrixFormField<T> extends FormField<T> {
  final ValueChanged<T>? onChange;
  final MatrixFormFieldBuilder<T> fieldBuilder;
  MatrixFormField({
    super.key,
    T? value,
    required this.onChange,
    required this.fieldBuilder,
    super.onSaved,
    super.validator,
  }) : super(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          initialValue: value,
          builder: (FormFieldState<T> field) {
            final _MatrixFormFieldState<T> state =
                field as _MatrixFormFieldState<T>;
            void onChangedHandler(T value) {
              field.didChange(value as T?);
              onChange?.call(value as T);
            }

            return fieldBuilder(
                value: state.value,
                errorText: state.errorText,
                onChange: onChangedHandler as ValueChanged<T>?);
            // value: state.value,
            // onChanged: onChanged == null ? null : state.didChange,
            // isFocused: isFocused,
          },
        );

  @override
  FormFieldState<T> createState() => _MatrixFormFieldState<T>();
}

class _MatrixFormFieldState<T> extends FormFieldState<T> {
  MatrixFormField<T> get _matrixFormField => widget as MatrixFormField<T>;

  @override
  void didChange(T? value) {
    super.didChange(value);
    _matrixFormField.onChange?.call(value as T);
  }

  @override
  void didUpdateWidget(MatrixFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }

  @override
  void reset() {
    super.reset();
    _matrixFormField.onChange?.call(value as T);
  }
}

Widget withFormField<T>(
  MatrixFormFieldBuilder<T> fieldBuilder, {
  required String label,
  required String name,
  bool required = false,
}) {
  return Builder(
    builder: (BuildContext context) {
      final store = useFormStore();
      // final CounterController counterController = Get.find();
      // return MatrixField(builder: builder(context, (dynamic v) => store.setField(name, 'value', v)))
      // return builder(context, (dynamic v) => store.setField(name, 'value', v));
      return Obx(() {
        return MatrixFormField<T>(
            validator: (v) {
              // print('validator ${required && (v == null || v == '')}');
              if (required && (v == null || v == '')) {
                return '必填';
              }
              return null;
            },
            onChange: (v) => store.setField(name, 'value', v),
            value: store.getField(name, 'value'),
            fieldBuilder: fieldBuilder);
      });
    },
  );

  // CheckboxFormField;
  // return FormField(builder: (BuildContext context ){
  //   final store = useFormStore();
  //   return builder(context, (dynamic v) => store.setField(name, 'value', v));
  // }, validator:(value){

  // })
}

import 'package:destroyer/components/matrix_form.dart';
import 'package:flutter/material.dart';

enum Direction { column, row }

// typedef FieldWidgetBuilder = Function(Widget controller, {Direction direction});

// Widget buildField(FieldWidgetBuilder builder,
//     {Direction direction = Direction.column}) {
//   return Field(component: builder, options: const {});
// }

// class Field extends StatelessWidget {
//   final Widget component;
//   final Map<String, dynamic> options;

//   const Field({super.key, required this.component, required this.options});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [component],
//     );
//   }
// }

typedef FormFieldBuilder<T> = Widget Function(
    BuildContext context, ValueChanged<String>? onChange);

Widget withFormField<T>(
  FormFieldBuilder<T> builder, {
  required String label,
  required String name,
  bool required = false,
}) {
  return Builder(
    builder: (BuildContext context) {
      final store = useFormStore();
      // return MatrixField(builder: builder(context, (dynamic v) => store.setField(name, 'value', v)))
      return builder(context, (dynamic v) => store.setField(name, 'value', v));
    },
  );
}

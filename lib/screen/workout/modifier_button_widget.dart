import 'package:flutter/material.dart';

class ModifierButtonWidget extends StatelessWidget {
  const ModifierButtonWidget({
    Key? key,
    required this.callback,
    required this.label,
  }) : super(key: key);

  final VoidCallback callback;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48.0,
      height: 24.0,
      child: OutlinedButton(
        onPressed: callback,
        child: Text(label),
      ),
    );
  }
}

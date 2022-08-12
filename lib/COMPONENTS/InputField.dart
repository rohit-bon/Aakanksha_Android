import 'package:flutter/material.dart';
import 'package:humanly/COMPONENTS/Constants.dart';

class InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final FocusNode focusNode;
  final int minLines;
  final int maxLines;
  final TextInputType keyboardType;
  final bool enable;
  final bool labelEnable;
  const InputField({
    Key key,
    this.label,
    this.controller,
    this.obscureText = false,
    this.focusNode,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.enable = true,
    this.labelEnable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: this.controller,
      enabled: this.enable,
      keyboardType:
          this.keyboardType != null ? this.keyboardType : TextInputType.text,
      focusNode: this.focusNode,
      obscureText: this.obscureText,
      decoration: InputDecoration(
        labelText: labelEnable ? this.label : null,
        hintText: this.label,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: kBorderColor,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: kPrimaryColor,
            width: 2,
          ),
        ),
      ),
      minLines: this.minLines,
      maxLines: this.maxLines,
      onChanged: (value) {},
    );
  }
}

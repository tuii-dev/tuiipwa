import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';

class FilledRoundedPinPut extends StatefulWidget {
  const FilledRoundedPinPut(
      {Key? key,
      required this.defaultPinWidth,
      required this.defaultPinHeight,
      required this.fontSize,
      required this.scaleUnit,
      required this.length,
      required this.completionCallback})
      : super(key: key);

  final double defaultPinWidth;
  final double defaultPinHeight;
  final double fontSize;
  final double scaleUnit;
  final int length;

  final void Function(String code) completionCallback;

  @override
  State<FilledRoundedPinPut> createState() => _FilledRoundedPinPutState();

  @override
  String toStringShort() => 'Rounded Filled';
}

class _FilledRoundedPinPutState extends State<FilledRoundedPinPut> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  bool showError = false;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color.fromRGBO(114, 178, 238, 1);
    const errorColor = Color.fromRGBO(255, 234, 238, 1);
    const fillColor = Color.fromRGBO(222, 231, 240, .57);
    final defaultPinTheme = PinTheme(
      width: widget.defaultPinWidth, // 56,
      height: widget.defaultPinHeight, // 60,
      textStyle: TextStyle(
        fontSize: widget.fontSize, // 22,
        color: TuiiColors.defaultText,
      ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return SizedBox(
      height: widget.defaultPinHeight + widget.scaleUnit, // 68,
      child: Pinput(
        autofocus: true,
        length: widget.length,
        controller: controller,
        focusNode: focusNode,
        defaultPinTheme: defaultPinTheme,
        onCompleted: (pin) {
          widget.completionCallback(pin);
        },
        focusedPinTheme: defaultPinTheme.copyWith(
          height: widget.defaultPinHeight + widget.scaleUnit,
          width: widget.defaultPinWidth + widget.scaleUnit,
          decoration: defaultPinTheme.decoration!.copyWith(
            border: Border.all(color: borderColor),
          ),
        ),
        errorPinTheme: defaultPinTheme.copyWith(
          decoration: BoxDecoration(
            color: errorColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

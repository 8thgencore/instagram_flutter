import 'package:flutter/material.dart';

class DialogButton extends StatelessWidget {
  final Function() onTap;
  final String text;

  const DialogButton({
    Key? key,
    required this.onTap,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Text(text),
      ),
    );
  }
}

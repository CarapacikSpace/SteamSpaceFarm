import 'package:flutter/material.dart';

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), width: 400, behavior: SnackBarBehavior.floating));
}

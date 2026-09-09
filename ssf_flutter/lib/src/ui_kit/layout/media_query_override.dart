import 'package:flutter/widgets.dart';

class const MediaQueryRootOverride({required final Widget child, super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(maxScaleFactor: 2, child: child);
  }
}

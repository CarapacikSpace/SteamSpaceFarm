import 'package:flutter/material.dart';
import 'package:space_farm/src/initialization/logic/composition_root.dart';
import 'package:space_farm/src/initialization/widget/dependencies_scope.dart';
import 'package:space_farm/src/initialization/widget/material_context.dart';
import 'package:space_farm/src/settings/widget/settings_scope.dart';

class RootContext extends StatelessWidget {
  const RootContext({required this.compositionResult, super.key});

  final CompositionResult compositionResult;

  @override
  Widget build(BuildContext context) {
    return DependenciesScope(
      dependencies: compositionResult.dependencies,
      child: const SettingsScope(child: MaterialContext()),
    );
  }
}

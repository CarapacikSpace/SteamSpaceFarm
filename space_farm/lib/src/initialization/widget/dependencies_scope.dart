import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:space_farm/src/common/extensions/context_extension.dart';
import 'package:space_farm/src/initialization/model/dependencies_container.dart';

class DependenciesScope extends InheritedWidget {
  const DependenciesScope({required super.child, required this.dependencies, super.key});

  final DependenciesContainer dependencies;

  static DependenciesContainer of(BuildContext context) => context.inhOf<DependenciesScope>(listen: false).dependencies;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DependenciesContainer>('dependencies', dependencies));
  }

  @override
  bool updateShouldNotify(DependenciesScope oldWidget) {
    return !identical(dependencies, oldWidget.dependencies);
  }
}

import 'package:flutter/widgets.dart';
import 'package:ssf_flutter/src/feature/app/model/dependencies_container.dart';
import 'package:ssf_flutter/src/feature/settings/widget/settings_scope.dart';

class const DependenciesScope({
  required final DependenciesContainer dependencies,
  required final Widget child,
  super.key,
}) extends StatelessWidget {
  static DependenciesContainer of(BuildContext context) {
    final _DependenciesInherited? scope = context.getInheritedWidgetOfExactType<_DependenciesInherited>();
    assert(scope != null, 'DependenciesScope is missing');
    return scope!.dependencies;
  }

  @override
  Widget build(BuildContext context) => _DependenciesInherited(
    dependencies: dependencies,
    child: SettingsScope(
      repository: dependencies.settingsRepository,
      initialSettings: dependencies.initialSettings,
      child: child,
    ),
  );
}

class const _DependenciesInherited({required final DependenciesContainer dependencies, required super.child})
    extends InheritedWidget {
  @override
  bool updateShouldNotify(_DependenciesInherited oldWidget) => !identical(dependencies, oldWidget.dependencies);
}

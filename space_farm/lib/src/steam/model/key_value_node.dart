class KeyValueNode {
  KeyValueNode({required this.name, required this.children, this.value});

  factory KeyValueNode.fromJson(Map<String, Object?> json) {
    return KeyValueNode(
      name: json['Name']! as String,
      value: json['Value'] as String?,
      children: (json['Children'] as List<dynamic>? ?? [])
          .map((child) => KeyValueNode.fromJson(child as Map<String, Object?>))
          .toList(),
    );
  }

  final String name;
  final String? value;
  final List<KeyValueNode> children;

  KeyValueNode? findNodeByName(String name) {
    if (this.name == name) {
      return this;
    }
    for (final child in children) {
      final found = child.findNodeByName(name);
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  List<KeyValueNode> findAllByName(String name) {
    final matches = <KeyValueNode>[];
    if (this.name == name) {
      matches.add(this);
    }
    for (final child in children) {
      matches.addAll(child.findAllByName(name));
    }
    return matches;
  }
}

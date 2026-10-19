class const CardDrops({
  required final int appId,
  required final String name,
  required final int? remaining,
  required final DateTime checkedAt,
}) {
  factory fromJson(Map<String, dynamic> json, {DateTime? checkedAt}) {
    final id = json['appId'] as int;
    final remaining = json['remaining'] as int?;
    if (id <= 0 || id > 0xffffffff || (remaining != null && remaining < 0)) {
      throw const FormatException('card_drops');
    }
    return CardDrops(
      appId: id,
      name: json['name'] as String,
      remaining: remaining,
      checkedAt: checkedAt ?? DateTime.fromMillisecondsSinceEpoch((json['checkedAt'] as int) * 1000),
    );
  }

  Map<String, dynamic> toJson() => {
    'appId': appId,
    'name': name,
    'remaining': remaining,
    'checkedAt': checkedAt.millisecondsSinceEpoch ~/ 1000,
  };
}

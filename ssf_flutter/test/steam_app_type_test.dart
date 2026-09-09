import 'package:flutter_test/flutter_test.dart';
import 'package:ssf_flutter/src/feature/catalog/model/local_app.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_app_type.dart';
import 'package:ssf_flutter/src/feature/steam/model/steam_library_snapshot.dart';

void main() {
  test('Steam types are recognized regardless of casing', () {
    for (final SteamAppType type in SteamAppType.values) {
      expect(SteamAppType.fromString(' ${type.name.toUpperCase()} '), type);
    }
    expect(SteamAppType.fromString(null), SteamAppType.other);
    expect(SteamAppType.fromString('Config'), SteamAppType.other);
  });

  test('refresh repairs cached Tool classification without losing user preferences', () {
    SteamLibrarySnapshot snapshot(String type) => SteamLibrarySnapshot.fromJson({
      'schemaVersion': 1,
      'steamId': '76561198000000001',
      'partial': false,
      'apps': [
        {'appId': 480, 'name': 'Example', 'type': type, 'ownership': 'family', 'hours': 3},
      ],
    });
    final LocalApp cached = snapshot('other').apps.single.copyWith(isFavorite: true);
    final LocalApp updated = snapshot('Tool').merge([cached]).single;
    expect(updated.type, SteamAppType.tool);
    expect(updated.isFavorite, isTrue);
    expect(updated.playtimeMinutes, 180);
  });
}

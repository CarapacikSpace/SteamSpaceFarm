import 'package:space_farm/src/steam/model/key_value_node.dart';
import 'package:space_farm/src/steam/model/steam_app_type.dart';

class SteamAppInfo {
  const SteamAppInfo({
    required this.appId,
    required this.type,
    this.name,
    this.reviewPercentage,
    this.isHidden = false,
    this.isOwnerOnly = false,
    this.logo,
    this.icon,
  });

  final int appId;
  final String? name;
  final SteamAppType type;
  final int? reviewPercentage;
  final bool isHidden;
  final bool isOwnerOnly;

  final String? logo;
  final String? icon;

  static List<SteamAppInfo> parseAppInfo(Map<String, dynamic> json) {
    SteamAppInfo parseAppInfo(String appId, Map<String, dynamic> appData) {
      final root = KeyValueNode.fromJson(appData);

      final aid = int.tryParse(root.findNodeByName('appid')?.value ?? appId) ?? int.parse(appId);
      final name = root.findNodeByName('name')?.value;
      final isHidden = root.findNodeByName('public_only')?.value == '1';
      final sectionType = root.findNodeByName('section_type')?.value;
      final isOwnerOnly = sectionType == 'ownersonly';
      final type = SteamAppType.fromString(root.findNodeByName('type')?.value, isOwnerOnly: isOwnerOnly);

      final reviewPercentage = int.tryParse(root.findNodeByName('review_percentage')?.value ?? '');

      String? getImageValue(String field) => root.findNodeByName(field)?.value;

      return SteamAppInfo(
        appId: aid,
        name: name,
        type: type,
        isHidden: isHidden,
        isOwnerOnly: isOwnerOnly,
        reviewPercentage: reviewPercentage,
        logo: getImageValue('logo'),
        icon: getImageValue('icon'),
      );
    }

    return json.entries.map((entry) {
      final appId = entry.key;
      final appData = entry.value as Map<String, dynamic>;
      return parseAppInfo(appId, appData);
    }).toList();
  }
}

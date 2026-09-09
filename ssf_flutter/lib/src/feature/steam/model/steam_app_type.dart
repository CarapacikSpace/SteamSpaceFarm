enum SteamAppType {
  game,
  demo,
  music,
  application,
  video,
  tool,
  dlc,
  other;

  factory fromString(String? type) => switch (type?.trim().toLowerCase()) {
    'game' => game,
    'demo' => demo,
    'music' => music,
    'application' => application,
    'video' => video,
    'tool' => tool,
    'dlc' => dlc,
    _ => other,
  };
}

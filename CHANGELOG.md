# Changelog

All notable changes to SteamSpaceFarm are documented here.

## 2.0

### Added

- Sign in with a QR code or password, complete Steam Guard, and reuse a protected session for future library updates.
- Import personal and Steam Family apps with names, playtime, and last-played data without a user-provided Web API key.
- Show library update progress, recoverable warnings, and session status in Steam settings, with separate sign-out and cache controls.

### Changed

- Rework the catalog, menus, filters, settings, notifications, and English/Russian translations into a consistent Steam-inspired interface.
- Isolate game processes, stagger normal batch starts and stops, and make Stop all immediately terminate SSF-owned game and library helper processes.
- Store settings, readable JSON library data, and protected sessions in the Windows application support directory.
- Consolidate library operations in the standalone `ssf_steam_helper.exe` and use direct Steam API calls in the NativeAOT `ssf_game.exe`.

### Removed

- Remove the old library fetchers, Web API key setup, legacy cache handling, and `localconfig.vdf` import workflow.

## 1.2

### Added

- Import games from Steam's `localconfig.vdf`.

### Changed

- Update the helper applications to .NET 10 and the Flutter application's Dart SDK to 3.13.

## 1.1.4

### Fixed

- Fix saving favorite games.
- Recognize Steam application links in search.
- Correct the layout of additional card types.

## 1.1

### Added

- Add English and Russian localization.
- Add three selectable card types.
- Add alphabetical and last-played sorting.

### Fixed

- Fix memory leaks.

## 1.0

- Initial release.

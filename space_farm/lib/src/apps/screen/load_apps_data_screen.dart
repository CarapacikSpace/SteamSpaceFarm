import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:space_farm/src/apps/data/apps_repository.dart';
import 'package:space_farm/src/apps/model/load_apps_data.dart';
import 'package:space_farm/src/common/extensions/context_extension.dart';
import 'package:space_farm/src/shared/elevated_button.dart';
import 'package:space_farm/src/shared/snackbar.dart';
import 'package:space_farm/src/shared/steam_switch.dart';
import 'package:space_farm/src/shared/text_button.dart';
import 'package:space_farm/src/shared/text_field.dart';
import 'package:url_launcher/url_launcher.dart';

enum _LoadAppsLoadingState { steamKit, webApi }

class LoadAppsDataScreen extends StatefulWidget {
  const LoadAppsDataScreen({super.key});

  @override
  State<LoadAppsDataScreen> createState() => _LoadAppsDataScreenState();
}

class _LoadAppsDataScreenState extends State<LoadAppsDataScreen> {
  late final IAppsRepository _appsRepository = context.dependencies.appsRepository;
  bool _downloadHiddenGames = true;

  late final _loginController = TextEditingController();
  late final _passwordController = TextEditingController();
  late final _apiKeyController = TextEditingController();
  late final _steamIdController = TextEditingController();

  bool _obscureLogin = true;
  bool _obscurePassword = true;
  bool _obscureApiKey = true;
  bool _saveLoginAndPassword = true;

  _LoadAppsLoadingState? _loadApps;
  bool _loadTimeout = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _apiKeyController.dispose();
    _steamIdController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final data = await _appsRepository.getLoadAppsData();
    final steamUser = await _appsRepository.loadSteamUserFromFile();
    if (steamUser?.steamId != null) {
      _steamIdController.text = steamUser!.steamId.toString();
    }
    if (data == null) {
      return;
    }
    _loginController.text = data.login;
    _passwordController.text = data.password;
    _apiKeyController.text = data.apiKey;
    if (steamUser == null) {
      _steamIdController.text = data.steamId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        await _appsRepository.killAllProcesses$SteamKit();
      },
      child: Scaffold(
        backgroundColor: const Color(0XFF171D25),
        appBar: AppBar(
          title: Text(context.l10n.loadGames),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              children: [
                ListTile(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                  title: Text(context.l10n.loadHiddenGamesData),
                  subtitle: Text(context.l10n.steamGuardNotice),
                  onTap: () => setState(() => _downloadHiddenGames = !_downloadHiddenGames),
                  trailing: SteamSwitch(
                    value: _downloadHiddenGames,
                    onChanged: (value) {
                      setState(() => _downloadHiddenGames = value);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedCrossFade(
                  firstChild: const LimitedBox(maxWidth: 0, child: SizedBox(width: double.infinity, height: 0)),
                  secondChild: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          spacing: 8,
                          children: [
                            Expanded(
                              child: Column(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(context.l10n.login, style: const TextStyle(fontSize: 14)),
                                  SteamTextField(
                                    controller: _loginController,
                                    obscureText: _obscureLogin,
                                    hintText: context.l10n.login,
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscureLogin ? Icons.visibility : Icons.visibility_off),
                                      onPressed: () => setState(() => _obscureLogin = !_obscureLogin),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(context.l10n.password, style: const TextStyle(fontSize: 14)),
                                  SteamTextField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    hintText: context.l10n.password,
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                        title: Text(context.l10n.saveLoginAndPassword),
                        onTap: () => setState(() => _saveLoginAndPassword = !_saveLoginAndPassword),
                        trailing: SteamSwitch(
                          value: _saveLoginAndPassword,
                          onChanged: (value) {
                            setState(() => _saveLoginAndPassword = value);
                          },
                        ),
                      ),
                    ],
                  ),
                  firstCurve: const Interval(0, 0.6, curve: Curves.fastOutSlowIn),
                  secondCurve: const Interval(0.4, 1, curve: Curves.fastOutSlowIn),
                  sizeCurve: Curves.fastOutSlowIn,
                  crossFadeState: _downloadHiddenGames ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 500),
                ),
                const SizedBox(height: 8),
                const Divider(color: Color(0xFF17191B), thickness: 2, height: 2),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.l10n.steamApiKey, style: const TextStyle(fontSize: 14)),
                            SteamTextField(
                              controller: _apiKeyController,
                              obscureText: _obscureApiKey,
                              hintText: context.l10n.steamApiKey,
                              suffixIcon: IconButton(
                                icon: Icon(_obscureApiKey ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SteamTextButton(
                        onPressed: () async {
                          await launchUrl(Uri.parse('https://steamcommunity.com/dev/apikey'));
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8,
                          children: [
                            Text(context.l10n.howToGet, style: const TextStyle(fontSize: 14, color: Color(0xFF1A9FFF))),
                            const Icon(Icons.arrow_forward, color: Color(0xFF1A9FFF)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.l10n.steamId, style: const TextStyle(fontSize: 14)),
                            SteamTextField(controller: _steamIdController, hintText: context.l10n.steamId),
                          ],
                        ),
                      ),
                      SteamTextButton(
                        onPressed: () async {
                          await launchUrl(Uri.parse('https://steamdb.info/calculator'));
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8,
                          children: [
                            Text(context.l10n.howToGet, style: const TextStyle(fontSize: 14, color: Color(0xFF1A9FFF))),
                            const Icon(Icons.arrow_forward, color: Color(0xFF1A9FFF)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _loadApps == null
                      ? SteamElevatedButton(
                          onPressed: () async => _loadAppsData(context),
                          child: Text(
                            '${context.l10n.loadAction}'
                                    ' ${_downloadHiddenGames ? context.l10n.loadAllIncludingHidden : ''}'
                                    ' ${context.l10n.loadActionGames}'
                                .toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      : Center(
                          child: Column(
                            spacing: 8,
                            children: [
                              const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF1A9FFF))),
                              if (_loadApps == _LoadAppsLoadingState.steamKit)
                                Text(
                                  context.l10n.loadFromSteamKit,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                )
                              else if (_loadApps == _LoadAppsLoadingState.webApi)
                                Text(
                                  context.l10n.loadFromWebApi,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        ),
                ),
                if (_loadTimeout)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      context.l10n.steamGuardRetryNotice,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadAppsData(BuildContext context) async {
    final data = LoadAppsData(
      login: _loginController.text.trim(),
      password: _passwordController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      steamId: _steamIdController.text.trim(),
    );
    late bool result;
    try {
      if (_downloadHiddenGames) {
        if (!data.validateAllGames()) {
          showSnack(context, context.l10n.emptyAuthFieldsError);
          return;
        }

        setState(() => _loadApps = _LoadAppsLoadingState.steamKit);

        _timeoutTimer = Timer(const Duration(seconds: 50), () => setState(() => _loadTimeout = true));

        await _appsRepository.saveLoadAppsData(data, saveLoginAndPassword: _saveLoginAndPassword);
        final userId = await _appsRepository.getApps$All(data.login, data.password, data.apiKey);
        if (userId != null) {
          _steamIdController.text = userId;
        }

        result = true;
        if (context.mounted) {
          showSnack(context, context.l10n.gamesLoadedFromAccount);
        }
      } else {
        if (!data.validateGames()) {
          showSnack(context, context.l10n.emptyApiKeyOrSteamIdError);
          return;
        }
        if (context.mounted) {
          setState(() => _loadApps = _LoadAppsLoadingState.webApi);
        }

        await _appsRepository.saveLoadAppsData(data, saveLoginAndPassword: _saveLoginAndPassword);
        await _appsRepository.getApps$Public(data.apiKey, data.steamId);

        result = true;
        if (context.mounted) {
          showSnack(context, context.l10n.gamesLoadedFromAccount);
        }
      }
    } on Exception catch (e, st) {
      log(e.toString(), error: e, stackTrace: st);
      if (context.mounted) {
        showSnack(context, e.toString());
      }
      result = false;
    } finally {
      _timeoutTimer?.cancel();
      if (context.mounted) {
        setState(() => _loadApps = null);
      }
    }

    if (result && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }
}

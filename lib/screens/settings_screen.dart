// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:silentshard/third_party/analytics.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/padded_container.dart';
import 'package:silentshard/services/app_preferences.dart';
import 'package:silentshard/services/local_auth_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

enum SettingsScreenState { ready, inProgress }

class _SettingsScreenState extends State<SettingsScreen> {
  final _currentYear = DateTime.now().year;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Silent Shard',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(defaultPadding * 1.5),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "Settings",
                style: textTheme.displayLarge,
              ),
              const SizedBox(
                height: defaultPadding * 2,
              ),
              Consumer<LocalAuth>(builder: (context, localAuth, _) {
                return SettingOption(
                    icon: const Icon(
                      Icons.fingerprint,
                      color: Colors.white,
                    ),
                    title: "Unlock using screen lock",
                    subtitle: '(Pin/Password/Fingerprint/Face ID)',
                    isSwitchOn: Provider.of<AppPreferences>(context, listen: false).getIsLocalAuthRequired(),
                    onChangeSwitch: (bool value) async {
                      bool res = await localAuth.authenticate();
                      if (res) {
                        Provider.of<AppPreferences>(context, listen: false).setIsLocalAuthRequired(value);
                        final analyticManager = Provider.of<AnalyticManager>(context, listen: false);
                        analyticManager.trackDeviceLockToggle(value);
                      }
                    });
              }),
              const Divider(),
              SettingOption(
                icon: const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                ),
                onTap: () async {
                  final url = Uri.parse('https://www.silencelaboratories.com/silent-shard-snap');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                title: "How Silent Shard works",
              ),
              const Divider(),
              SettingOption(
                icon: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                ),
                onTap: () async {
                  final url = Uri.parse('https://silencelaboratories.com/privacy');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                title: "Privacy Policy",
              ),
              const Divider(),
              SettingOption(
                icon: const Icon(
                  Icons.file_copy_outlined,
                  color: Colors.white,
                ),
                onTap: () async {
                  final url = Uri.parse(
                      'https://silence-laboratories.gitbook.io/silent-shard-phone-+-cloud-mpc-tss-sdk/~/changes/kKCywQovqWCTefwcckYV/silent-shard-mpc-tss-sl');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                title: "SDK Documentation",
              ),
              const Divider(),
              SettingOption(
                icon: const Icon(
                  Icons.description_outlined,
                  color: Colors.white,
                ),
                onTap: () async {
                  showLicensePage(
                    context: context,
                    applicationIcon: Image.asset('assets/icon/silentShardLogo.png', width: 64, height: 64),
                    applicationName: _packageInfo.appName,
                    applicationVersion: _packageInfo.version,
                    applicationLegalese: '© $_currentYear ${_packageInfo.appName}',
                  );
                },
                title: "Licenses",
              ),
              const Divider(),
              Container(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "For any queries reach out to",
                      style: textTheme.displaySmall,
                    ),
                    const SizedBox(
                      height: defaultPadding * 1.5,
                    ),
                    GestureDetector(
                        onTap: () {
                          Uri emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: 'snap@silencelaboratories.com',
                          );
                          launchUrl(emailLaunchUri);
                        },
                        child: Text(
                          "snap@silencelaboratories.com",
                          style: textTheme.headlineSmall,
                        ))
                  ],
                ),
              ),
              const Gap(defaultPadding * 2),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                GestureDetector(
                  onTap: () async {
                    final url = Uri.parse('https://twitter.com/silencelabs_sl');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  child: Image.asset(
                    'assets/images/socialX.png',
                    height: 30,
                  ),
                ),
                const Gap(defaultPadding * 2),
                const Gap(defaultPadding * 2),
                GestureDetector(
                  onTap: () async {
                    final url = Uri.parse('https://github.com/silence-laboratories');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  child: Image.asset(
                    'assets/images/socialGit.png',
                    height: 30,
                  ),
                )
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

class SettingOption extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final bool? isSwitchOn;
  final Future<void> Function()? onTap;
  final Function(bool value)? onChangeSwitch;
  const SettingOption({
    super.key,
    required this.icon,
    required this.title,
    this.isSwitchOn,
    this.onChangeSwitch,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    bool hasSwitch = isSwitchOn != null && onChangeSwitch != null;
    return hasSwitch
        ? GestureDetector(
            onTap: () async {
              if (onTap != null) {
                await onTap!();
              }
            },
            child: _buildContainer(textTheme, hasSwitch),
          )
        : InkWell(
            onTap: () async {
              if (onTap != null) {
                await onTap!();
              }
            },
            splashColor: const Color(0xFF151515),
            child: _buildContainer(textTheme, hasSwitch),
          );
  }

  Widget _buildContainer(TextTheme textTheme, bool hasSwitch) {
    return Container(
      padding: const EdgeInsets.only(top: defaultPadding * 2, bottom: defaultPadding * 2, left: defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PaddedContainer(child: icon),
          const Gap(defaultPadding),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: textTheme.displaySmall),
              if (subtitle != null) Text(subtitle!, style: textTheme.bodySmall),
            ]),
          ),
          if (hasSwitch)
            Switch(
              thumbColor: const MaterialStatePropertyAll(textPrimaryColor),
              value: isSwitchOn!,
              activeColor: backgroundPrimaryColor,
              onChanged: onChangeSwitch,
            )
        ],
      ),
    );
  }
}

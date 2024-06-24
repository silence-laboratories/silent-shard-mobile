import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/fade_in_out.dart';
import 'package:silentshard/screens/update/app_update.dart';
import 'package:silentshard/screens/update/snap_and_app_update.dart';
import 'package:silentshard/screens/update/snap_update.dart';
import 'package:silentshard/screens/update/snap_updated_succesfully.dart';
import 'package:silentshard/screens/update/update_snap_guide.dart';
import 'package:silentshard/services/app_updater_service.dart';
import 'package:silentshard/services/snap_service.dart';
import 'package:url_launcher/url_launcher.dart';

enum UpdateAlertDialogState {
  noAlert,
  showSnapUpdateGuide,
  showSnapUpdateSuccessful,
  showSnapUpdateAvailable,
  showAppUpdateAvailble,
  showSnapAndAppUpdateAvailable
}

class UpdaterDialog extends StatefulWidget {
  final bool showSnapUpdate;
  const UpdaterDialog({super.key, this.showSnapUpdate = true});

  @override
  State<UpdaterDialog> createState() => _UpdaterState();
}

class _UpdaterState extends State<UpdaterDialog> {
  bool showSnapUpdateGuide = false;
  bool showSnapUpdateSuccessful = false;
  int imageLoading = 2; // Load 2 images

  final Map<String, Image> imageMap = {
    PrecachedImageKeys.uploadRocket: Image.asset('assets/images/updateRocket.png', width: 150),
    PrecachedImageKeys.uploadLaptop: Image.asset('assets/images/updateLaptop.png', width: 250),
  };

  @override
  void didChangeDependencies() {
    imageMap.forEach((key, value) {
      precacheImage(value.image, context).then((_) {
        setState(() {
          imageLoading--;
        });
      });
    });
    super.didChangeDependencies();
  }

  _updateShowSnapUpdateGuide(bool value) {
    setState(() {
      showSnapUpdateGuide = value;
    });
  }

  _handleAppUpdate() {
    Uri emailLaunchUri = Uri.parse(
      Platform.isAndroid ? "market://details?id=com.silencelaboratories.silentshard" : "https://apps.apple.com/app/id6468993285",
    );
    launchUrl(
      emailLaunchUri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Consumer<SnapService>(
      builder: (context, snapService, _) => Consumer<AppUpdaterService>(builder: (context, appUpdaterService, _) {
        if (appUpdaterService.forceUpdateApp != null && imageLoading <= 0) {
          UpdateAlertDialogState updateAlertDialogState = switch ((
            appUpdaterService.forceUpdateApp!,
            widget.showSnapUpdate && (snapService.forceUpdateSnap ?? false),
            widget.showSnapUpdate && showSnapUpdateGuide,
            widget.showSnapUpdate && snapService.showSnapUpdateSuccessful
          )) {
            (false, true, false, false) => UpdateAlertDialogState.showSnapUpdateAvailable,
            (_, true, true, false) => UpdateAlertDialogState.showSnapUpdateGuide,
            (_, _, _, true) => UpdateAlertDialogState.showSnapUpdateSuccessful,
            (true, true, false, false) => UpdateAlertDialogState.showSnapAndAppUpdateAvailable,
            (true, false, _, _) => UpdateAlertDialogState.showAppUpdateAvailble,
            (false, false, _, false) => UpdateAlertDialogState.noAlert
          };
          return Stack(
            children: [
              if (updateAlertDialogState != UpdateAlertDialogState.noAlert)
                const IgnorePointer(
                  ignoring: false,
                  child: Opacity(
                    opacity: 0,
                    child: ModalBarrier(
                      color: Colors.grey,
                    ),
                  ),
                ),
              FadeInOut(
                visible: updateAlertDialogState == UpdateAlertDialogState.showSnapUpdateGuide,
                child: UpdateSnapGuide(
                  textTheme: textTheme,
                  onBack: () {
                    _updateShowSnapUpdateGuide(false);
                  },
                  image: imageMap[PrecachedImageKeys.uploadLaptop]!,
                ),
              ),
              FadeInOut(
                visible: updateAlertDialogState == UpdateAlertDialogState.showSnapUpdateAvailable,
                child: SnapUpdate(
                  textTheme: textTheme,
                  onPressSnapGuide: () {
                    _updateShowSnapUpdateGuide(true);
                  },
                  image: imageMap[PrecachedImageKeys.uploadRocket]!,
                ),
              ),
              FadeInOut(
                visible: updateAlertDialogState == UpdateAlertDialogState.showSnapUpdateSuccessful,
                child: SnapUpdatedSuccesfully(
                    textTheme: textTheme,
                    onContinue: () {
                      snapService.showSnapUpdateSuccessful = false;
                    }),
              ),
              FadeInOut(
                visible: updateAlertDialogState == UpdateAlertDialogState.showSnapAndAppUpdateAvailable,
                child: SnapAndAppUpdate(
                  textTheme: textTheme,
                  onAppUpdate: _handleAppUpdate,
                  onPressSnapGuide: () {
                    _updateShowSnapUpdateGuide(true);
                  },
                  image: imageMap[PrecachedImageKeys.uploadRocket]!,
                ),
              ),
              FadeInOut(
                visible: updateAlertDialogState == UpdateAlertDialogState.showAppUpdateAvailble,
                child: AppUpdate(
                  textTheme: textTheme,
                  onAppUpdate: _handleAppUpdate,
                  image: imageMap[PrecachedImageKeys.uploadRocket]!,
                ),
              ),
            ],
          );
        } else {
          return Container();
        }
      }),
    );
  }
}

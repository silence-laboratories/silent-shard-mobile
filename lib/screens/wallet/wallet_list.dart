import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/demo/state_decorators/keyshares_provider.dart';
import 'package:silentshard/repository/app_repository.dart';
import 'package:silentshard/screens/backup_destination/backup_destination_screen.dart';
import 'package:silentshard/screens/scanner/scanner_screen.dart';
import 'package:silentshard/screens/sign/confirm_unpair.dart';
import 'package:silentshard/screens/wallet/wallet_card.dart';
import 'package:silentshard/types/wallet_highlight_provider.dart';

class WalletList extends StatefulWidget {
  const WalletList({super.key});
  @override
  WalletListState createState() => WalletListState();
}

class WalletListState extends State<WalletList> {
  final ScrollController _scrollController = ScrollController();

  void _repair(String repairWalletId, String repairAddress) async {
    FirebaseCrashlytics.instance.log('Initiated repair');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(isRePairing: true, recoveryWalletId: repairWalletId, repairAddress: repairAddress),
      ),
    );
  }

  void _exportBackup(String walletId, String address) async {
    FirebaseCrashlytics.instance.log('Open export backup');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BackupDestinationScreen(walletId: walletId, address: address),
      ),
    );
  }

  void _confirmSignOut(String walletId, String address) {
    FirebaseCrashlytics.instance.log('Initiated sign out');
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: sheetBackgroundColor,
        barrierColor: Colors.white.withOpacity(0.15),
        showDragHandle: true,
        context: context,
        builder: (context) => ConfirmUnpair(walletId: walletId, address: address, onUnpair: _signOut));
  }

  Future<void> _signOut(String walletId) async {
    FirebaseCrashlytics.instance.log('Signing out');
    Provider.of<AppRepository>(context, listen: false).reset(walletId);
  }

  int _scrollToListener(String pairedWalletId, List<MapEntry<String, List<Keyshare>>> walletEntries) {
    int scrolledToIndex = 0;
    for (var i = 0; i < walletEntries.length; i++) {
      if (walletEntries[i].key == pairedWalletId) {
        scrolledToIndex = i;
        break;
      }
    }
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        (scrolledToIndex * 150.0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    }

    return scrolledToIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        controller: _scrollController,
        child: Consumer<KeysharesProvider>(
            builder: (context, keysharesProvider, _) => Consumer<WalletHighlightProvider>(builder: (context, walletIdProvider, child) {
                  var walletEntries = keysharesProvider.keyshares.entries.toList();
                  var scrolledToIndex = _scrollToListener(walletIdProvider.pairedWalletId, walletEntries);
                  return ListView.builder(
                    itemCount: walletEntries.length,
                    itemBuilder: (context, index) {
                      final walletEntry = walletEntries[index];
                      final walletId = walletEntry.key;
                      final keyshareList = walletEntry.value;
                      final address = keyshareList.firstOrNull?.ethAddress ?? "";
                      return Container(
                        margin: const EdgeInsets.only(bottom: defaultSpacing * 3),
                        decoration: (index == scrolledToIndex && walletIdProvider.scrolled)
                            ? BoxDecoration(
                                color: const Color(0xFF25194D),
                                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                border: Border.all(
                                  color: const Color(0xFF745EF6),
                                  width: 1.0,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xB2745EF6),
                                    blurRadius: 20.0,
                                    spreadRadius: 0.0,
                                    offset: Offset(0.0, 0.0),
                                  ),
                                ],
                                shape: BoxShape.rectangle,
                              )
                            : BoxDecoration(
                                border: Border.all(width: 1, color: secondaryColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(8.0),
                          child: WalletCard(
                            key: Key(walletId),
                            walletId: walletId,
                            onRepair: () {
                              _repair(walletId, address);
                            },
                            onExport: () => _exportBackup(walletId, address),
                            onLogout: () => _confirmSignOut(walletId, address),
                            address: address,
                            onCopy: () async {
                              await Clipboard.setData(ClipboardData(text: address));
                            },
                          ),
                        ),
                      );
                    },
                  );
                })));
  }
}
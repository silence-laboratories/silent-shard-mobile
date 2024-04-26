import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/repository/app_repository.dart';
import 'package:silentshard/screens/backup_destination/backup_destination_screen.dart';
import 'package:silentshard/screens/scanner/scanner_screen.dart';
import 'package:silentshard/screens/sign/confirm_unpair.dart';
import 'package:silentshard/screens/wallet/wallet_card.dart';

class WalletList extends StatefulWidget {
  const WalletList({super.key, required this.walletEntries});
  final List<MapEntry<String, List<Keyshare>>> walletEntries;

  @override
  _WalletListState createState() => _WalletListState();
}

class _WalletListState extends State<WalletList> {
  final ScrollController _scrollController = ScrollController();
  bool isScrolled = false;

  void addNewWallet(String wallet) {
    setState(() {
      isScrolled = true;
    });
    // Animate to the end of the list when a new wallet is added
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100, // Adjust this value as needed
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _repair() async {
    FirebaseCrashlytics.instance.log('Initiated repair');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScannerScreen(isRePairing: true),
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.walletEntries.length,
      itemBuilder: (context, index) {
        final walletEntry = widget.walletEntries[index];
        final walletId = walletEntry.key;
        final keyshareList = walletEntry.value;
        final address = keyshareList.firstOrNull?.ethAddress ?? "";
        return Container(
          decoration: (index == widget.walletEntries.length - 1 && isScrolled)
              ? BoxDecoration(
                  color: const Color(0xB325194D),
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
            onTap: () => setState(() {
              isScrolled = false;
            }),
            borderRadius: BorderRadius.circular(8.0),
            child: WalletCard(
              key: Key(walletId),
              walletId: walletId,
              onRepair: _repair,
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
  }
}

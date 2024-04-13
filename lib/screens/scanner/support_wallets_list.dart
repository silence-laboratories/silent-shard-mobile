import 'package:flutter/material.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/wallet/wallet_menu.dart';
import 'package:silentshard/types/support_wallet.dart';

class SupportWalletList extends StatefulWidget {
  const SupportWalletList({
    super.key,
    required this.onBack,
    required this.supportWallets,
  });
  final Function onBack;
  final List<SupportWallet> supportWallets;

  @override
  State<StatefulWidget> createState() {
    return _SupportWalletListState();
  }
}

class _SupportWalletListState extends State<SupportWalletList> {
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return ListView(
      children: <Widget>[
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                widget.onBack();
              },
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: defaultPadding * 1.5),
                child: Text(
                  'Supported wallet',
                  style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(defaultPadding * 4),
          child: Column(children: [
            ...widget.supportWallets.map((SupportWallet wallet) {
              return WalletOption(
                icon: Image.asset(
                  wallet.icon,
                  height: 24,
                ),
                title: Text(wallet.name, style: textTheme.displayMedium),
              );
            })
          ]),
        ),
      ],
    );
  }
}

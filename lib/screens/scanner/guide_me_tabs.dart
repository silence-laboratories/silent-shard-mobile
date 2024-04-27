import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/button.dart';
import 'package:silentshard/screens/scanner/bullet_list.dart';
import 'package:silentshard/screens/scanner/support_wallets_list.dart';
import 'package:silentshard/types/support_wallet.dart';

class GuideMeTabController extends StatefulWidget {
  const GuideMeTabController({required this.isRePairing, super.key});
  final bool? isRePairing;
  @override
  State<StatefulWidget> createState() {
    return GuideMeTabControllerState();
  }
}

class GuideMeTabControllerState extends State<GuideMeTabController> {
  bool showSupportWallets = false;
  List<SupportWallet> supportWallets = walletMetaData.entries
      .map((entry) => SupportWallet(name: entry.value['name'] ?? "", icon: entry.value['icon'] ?? ""))
      .where((e) => e.name != "Metamask")
      .toList();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return showSupportWallets
        ? SupportWalletList(
            supportWallets: supportWallets,
            onBack: () {
              setState(() {
                showSupportWallets = false;
              });
            })
        : DefaultTabController(
            length: 2,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(defaultSpacing * 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Gap(defaultSpacing),
                    Text(
                      'How to connect wallet using',
                      style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const TabBar(
                      tabs: [
                        Tab(text: 'Meta Mask'),
                        Tab(text: 'Other wallet'),
                      ],
                      labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: primaryColor2),
                      dividerColor: Color(0x804A408D),
                      indicatorColor: primaryColor2,
                      indicatorSize: TabBarIndicatorSize.tab,
                    ),
                    SizedBox(
                      height: 375,
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 2, vertical: defaultSpacing * 3),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Image.asset(
                                        'assets/images/metamaskIcon.png',
                                        height: 18,
                                      ),
                                    ),
                                    const Gap(defaultSpacing),
                                    Text('MetaMask Snap', style: textTheme.displaySmall?.copyWith(color: textGrey))
                                  ],
                                ),
                                const Gap(defaultSpacing * 2),
                                BulletList(isOtherWalletInstructor: false, isRePairing: widget.isRePairing)
                              ]),
                            ),
                          ),
                          // Other wallet
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 2, vertical: defaultSpacing * 3),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                CheckWalletButton(
                                  supportWalletsCount: supportWallets.length,
                                  onShowSupportWallets: () {
                                    setState(() {
                                      showSupportWallets = true;
                                    });
                                  },
                                ),
                                const Gap(defaultSpacing * 2),
                                const BulletList(isOtherWalletInstructor: true)
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Button(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Back to scanning', style: textTheme.displayMedium),
                    ),
                    // Add space
                  ],
                ),
              ),
            ));
  }
}

class CheckWalletButton extends StatelessWidget {
  const CheckWalletButton({super.key, required this.onShowSupportWallets, required this.supportWalletsCount});
  final Function onShowSupportWallets;
  final int supportWalletsCount;

  Widget overlapped() {
    const overlap = 20.0;
    final items = [
      CircleAvatar(
        maxRadius: 12,
        backgroundColor: Colors.white,
        child: Image.asset(
          'assets/images/biconomy.png',
          height: 18,
        ),
      ),
      CircleAvatar(
        maxRadius: 12,
        backgroundColor: Colors.white,
        child: Image.asset(
          'assets/images/stackup.png',
          height: 18,
        ),
      ),
      CircleAvatar(
        maxRadius: 12,
        backgroundColor: Colors.white,
        child: Image.asset(
          'assets/images/zerodev.png',
          height: 18,
        ),
      ),
    ];

    List<Widget> stackLayers = List<Widget>.generate(items.length, (index) {
      return Padding(
        padding: EdgeInsets.fromLTRB(index.toDouble() * overlap, 0, 0, 0),
        child: items[index],
      );
    });

    return Stack(
      children: stackLayers.reversed.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF5833CF), width: 1),
          backgroundColor: secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: defaultSpacing, horizontal: defaultSpacing * 1.5),
        ),
        onPressed: () {
          onShowSupportWallets();
        },
        child: SizedBox(
          width: double.infinity,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text('Check all support wallet', style: textTheme.displaySmall?.copyWith(color: textGrey)),
              Container(
                  margin: const EdgeInsets.only(left: defaultSpacing),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      overlapped(),
                      Padding(
                        padding: const EdgeInsets.only(right: defaultSpacing, left: defaultSpacing / 2),
                        child: Text('+$supportWalletsCount', style: textTheme.displayMedium?.copyWith(color: textGrey)),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFFB1BBC8),
                      )
                    ],
                  )),
            ],
          ),
        ));
  }
}
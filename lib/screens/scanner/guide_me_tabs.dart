import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/bullet.dart';
import 'package:silentshard/screens/components/button.dart';

class GuideMeTabController extends StatelessWidget {
  const GuideMeTabController({required this.isRePairing, super.key});

  final bool? isRePairing;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return DefaultTabController(
        length: 2,
        child: Wrap(
          children: [
            Container(
              padding: const EdgeInsets.all(defaultPadding * 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Gap(defaultPadding),
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
                            padding: const EdgeInsets.symmetric(horizontal: defaultPadding * 2, vertical: defaultPadding * 3),
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
                                  const Gap(defaultPadding),
                                  Text('MetaMask Snap', style: textTheme.displaySmall?.copyWith(color: textGrey))
                                ],
                              ),
                              const Gap(defaultPadding * 2),
                              Bullet(
                                child: RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(text: 'Open ', style: textTheme.displaySmall),
                                      TextSpan(
                                          text: 'snap.silencelaboratories.com', style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: ' in your desktop.', style: textTheme.displaySmall),
                                    ],
                                  ),
                                ),
                              ),
                              Bullet(
                                child: Text("Connect Silent Shard Snap with your MetaMask extension.", style: textTheme.displaySmall),
                              ),
                              if (isRePairing == true)
                                Bullet(
                                  child: RichText(
                                    text: TextSpan(
                                      children: <InlineSpan>[
                                        TextSpan(text: 'If account is already present:  press on the', style: textTheme.displaySmall),
                                        const WidgetSpan(
                                          child: Icon(
                                            Icons.more_vert,
                                            size: 20,
                                          ),
                                        ),
                                        TextSpan(
                                            text: 'icon and click on ‘Recover account on phone’ and follow the instructions',
                                            style: textTheme.displaySmall),
                                      ],
                                    ),
                                  ),
                                ),
                              Bullet(
                                child: RichText(
                                  text: TextSpan(
                                    children: <InlineSpan>[
                                      TextSpan(text: 'Scan QR code with ', style: textTheme.displaySmall),
                                      WidgetSpan(
                                        child: Image.asset('assets/icon/silentShardLogo.png', height: 20, width: 20),
                                      ),
                                      TextSpan(text: ' Silent Shard', style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: ' logo and connect this device.', style: textTheme.displaySmall),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                        // Other wallet
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: defaultPadding * 2, vertical: defaultPadding * 3),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              CheckWalletButton(),
                              const Gap(defaultPadding * 2),
                              Bullet(
                                child: Text("Head over to your favourite SilentShard-supported wallets (coming soon...) on your browser to desktop.",
                                    style: textTheme.displaySmall),
                              ),
                              Bullet(
                                child: Text("Follow the instructions to create a new distributed wallet.", style: textTheme.displaySmall),
                              ),
                              Bullet(
                                child: RichText(
                                  text: TextSpan(
                                    children: <InlineSpan>[
                                      TextSpan(text: 'Scan QR code with ', style: textTheme.displaySmall),
                                      WidgetSpan(
                                        child: Image.asset('assets/icon/silentShardLogo.png', height: 20, width: 20),
                                      ),
                                      TextSpan(text: ' Silent Shard', style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: ' logo and connect this device.', style: textTheme.displaySmall),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Button(
                    onPressed: () {},
                    child: Text('Back to scanning', style: textTheme.displayMedium),
                  ),
                  // Add space
                ],
              ),
            )
          ],
        ));
  }
}

class CheckWalletButton extends StatelessWidget {
  Widget overlapped() {
    final overlap = 30.0;
    final items = [
      CircleAvatar(
        backgroundColor: Colors.white,
        child: Image.asset(
          'assets/images/biconomy.png',
          height: 24,
        ),
      ),
      CircleAvatar(
        backgroundColor: Colors.white,
        child: Image.asset(
          'assets/images/stackup.png',
          height: 24,
        ),
      ),
      CircleAvatar(
        backgroundColor: Colors.white,
        child: Image.asset(
          'assets/images/zerodev.png',
          height: 24,
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
        padding: const EdgeInsets.symmetric(vertical: defaultPadding, horizontal: defaultPadding * 1.5),
      ),
      onPressed: () {},
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('Check all support wallet', style: textTheme.displayMedium?.copyWith(color: textGrey)),
          const Gap(defaultPadding),
          const Spacer(),
          overlapped(),
          const Gap(defaultPadding),
          Text('+5', style: textTheme.displayMedium?.copyWith(color: textGrey)), // TODO: Remove hardcode
          const Gap(defaultPadding),
          const Icon(
            Icons.arrow_forward,
            color: Color(0xFFB1BBC8),
          )
        ],
      ),
    );
  }
}

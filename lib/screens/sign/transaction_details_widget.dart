// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:silentshard/screens/components/ShimmerNetworkIcon.dart';
import 'package:silentshard/screens/components/copy_button.dart';
import 'package:silentshard/services/wallet_metadata_loader.dart';
import 'package:silentshard/types/support_wallet.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:lottie/lottie.dart';

import '../../constants.dart';
import '../../demo/state_decorators/keyshares_provider.dart';
import '../../utils.dart';
import '../sign/sign_request_view_model.dart';
import 'wallet_address_widget.dart';

class TransactionDetailsWidget extends StatelessWidget {
  final SignRequestViewModel requestModel;
  final void Function(bool approved, SignRequestViewModel requestModel, {Function? onErrorCb}) handleSignResponse;
  final String walletId;
  final String address;

  const TransactionDetailsWidget(
      {super.key, //
      required this.requestModel,
      required this.handleSignResponse,
      required this.walletId,
      required this.address});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    var outputFormat = DateFormat('hh:mm a, dd/MM/yyyy ');
    WalletMetadataLoader walletMetadataLoader = Provider.of<WalletMetadataLoader>(context, listen: false);
    SupportWallet walletInfo = walletMetadataLoader.getWalletMetadata(walletId);

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: FutureBuilder<Chain>(
        future: requestModel.chain,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Lottie.asset('assets/lottie/MobileLoader.json'),
            );
          }
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.only(left: defaultSpacing * 1.5, right: defaultSpacing * 1.5, top: defaultSpacing * 3),
              child: Text(
                'Approve transaction?',
                style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Gap(defaultSpacing),
            Container(
              padding: const EdgeInsets.all(defaultSpacing * 1.5),
              child: Row(
                children: [
                  ShimmerNetworkIcon(
                    icon: walletInfo.icon,
                    height: 28,
                  ),
                  const Gap(defaultSpacing),
                  Consumer<KeysharesProvider>(builder: (context, keysharesProvider, _) {
                    return WalletAddressWidget(
                      title: 'From wallet',
                      displayText: address,
                      copyText: address,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    );
                  }),
                  const Spacer(),
                  if (requestModel.recipient != null)
                    WalletAddressWidget(
                      title: 'To wallet',
                      displayText: requestModel.recipient!,
                      copyText: requestModel.recipient!,
                      crossAxisAlignment: CrossAxisAlignment.end,
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(defaultSpacing * 1.5),
              width: MediaQuery.of(context).size.width,
              color: backgroundPrimaryColor.withOpacity(0.1),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (requestModel.signType.isTransaction) ...[
                  Text(
                    "Message",
                    style: textTheme.bodyMedium,
                  ),
                  const Gap(defaultSpacing * 1.5),
                  Text(
                    '${requestModel.amount ?? '0'} ${snapshot.data?.code ?? 'Unknown'}',
                    style: textTheme.displayLarge,
                  ),
                ] else ...[
                  Text(
                    "Transaction Type",
                    style: textTheme.bodyMedium,
                  ),
                  const Gap(defaultSpacing * 1.5),
                  Text(
                    switch (requestModel.signType) {
                      SignType.legacyTransaction => 'Legacy Transaction',
                      SignType.ethTransaction => 'Eth Transaction',
                      SignType.ethSign => 'Eth Sign',
                      SignType.personalSign => 'Personal Sign',
                      SignType.ethSignTypedData => 'Signed Typed Data',
                      SignType.ethSignTypedDataV1 => 'Signed Typed Data V1',
                      SignType.ethSignTypedDataV2 => 'Signed Typed Data V2',
                      SignType.ethSignTypedDataV3 => 'Signed Typed Data V3',
                      SignType.ethSignTypedDataV4 => 'Signed Typed Data V4',
                    },
                    style: textTheme.displayMedium,
                  ),
                  const Gap(defaultSpacing * 2),
                  Text(
                    "Message",
                    style: textTheme.bodyMedium,
                  ),
                  const Gap(defaultSpacing * 1.5),
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Flexible(
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        requestModel.signType == SignType.personalSign ? hexToAscii(requestModel.displayMessage) : requestModel.displayMessage,
                        style: textTheme.displayMedium,
                      ),
                    ),
                    CopyButton(
                      followerAnchor: Alignment.topCenter,
                      onCopy: () async {
                        final copyText =
                            requestModel.signType == SignType.personalSign ? hexToAscii(requestModel.displayMessage) : requestModel.displayMessage;
                        await Clipboard.setData(ClipboardData(text: copyText));
                      },
                    ),
                  ])
                ],
              ]),
            ),
            Container(
              padding: const EdgeInsets.all(defaultSpacing * 1.5),
              child: Column(
                children: [
                  const Gap(defaultSpacing),
                  if (!requestModel.signType.isTransaction)
                    Row(
                      children: [
                        Text('Requested at', style: textTheme.bodyMedium),
                        const Spacer(),
                        Flexible(
                          flex: 3,
                          child: Text(
                            outputFormat.format(DateTime.now()).toLowerCase(),
                            style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        )
                      ],
                    ),
                  if (requestModel.signType.isTransaction)
                    Container(
                      padding: const EdgeInsets.all(defaultSpacing * 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF222222),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('Chain',
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.6,
                                    color: textSecondaryColor,
                                  )),
                              const Spacer(),
                              Text(
                                snapshot.data?.name ?? 'Unknown',
                                style: const TextStyle(
                                  color: textPrimaryColor,
                                  fontSize: 14,
                                  height: 1.6,
                                  fontFamily: 'Epilogue',
                                ),
                              ),
                            ],
                          ),
                          const Gap(defaultSpacing * 2),
                          Row(
                            children: [
                              const Text('Requested at',
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.6,
                                    color: textSecondaryColor,
                                  )),
                              const Spacer(),
                              Flexible(
                                flex: 3,
                                child: Text(
                                  outputFormat.format(DateTime.now()).toLowerCase(),
                                  style: const TextStyle(
                                    color: textPrimaryColor,
                                    fontSize: 14,
                                    height: 1.6,
                                    fontFamily: 'Epilogue',
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  const Gap(defaultSpacing * 5),
                  SlideAction(
                    borderRadius: 10,
                    elevation: 0,
                    innerColor: const Color(0xFFC5C8FF),
                    outerColor: backgroundPrimaryColor,
                    text: "Slide to Approve",
                    height: 50,
                    sliderButtonIconPadding: 15,
                    textStyle: textTheme.displaySmall,
                    sliderButtonIconSize: 20,
                    onSubmit: () {
                      handleSignResponse(true, requestModel);
                      return null;
                    },
                  ),
                  TextButton(
                      onPressed: () {
                        handleSignResponse(false, requestModel);
                      },
                      child: const Text(
                        'Reject',
                        style: TextStyle(color: primaryColor),
                      )),
                ],
              ),
            )
          ]);
        },
      ),
    );
  }
}

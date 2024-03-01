// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../constants.dart';
import '../../demo/state_decorators/keyshares_provider.dart';
import '../../utils.dart';
import '../sign/sign_request_view_model.dart';
import 'wallet_address_widget.dart';

class TransactionDetailsWidget extends StatelessWidget {
  final SignRequestViewModel requestModel;
  final void Function(bool approved, SignRequestViewModel requestModel, {Function? onErrorCb}) handleSignResponse;

  const TransactionDetailsWidget({
    super.key,
    required this.requestModel,
    required this.handleSignResponse,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    var outputFormat = DateFormat('hh:mm a, dd/MM/yyyy ');

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.only(left: defaultPadding * 1.5, right: defaultPadding * 1.5, top: defaultPadding * 3),
          child: Text(
            'Approve transaction?',
            style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const Gap(defaultPadding),
        Container(
          padding: const EdgeInsets.all(defaultPadding * 1.5),
          child: Row(
            children: [
              Consumer<KeysharesProvider>(builder: (context, keysharesProvider, _) {
                var address = keysharesProvider.keyshares.firstOrNull?.ethAddress;
                return WalletAddressWidget(
                  title: 'From wallet',
                  // displayText: address != null ? "${address.substring(0, 5)}....${address.substring(address.length - 5)}" : "Unknown address",
                  displayText: address ?? "Unknown address",
                  copyText: address!,
                  crossAxisAlignment: CrossAxisAlignment.start,
                );
              }),
              const Spacer(),
              if (requestModel.recipient != null)
                WalletAddressWidget(
                  title: 'To wallet',
                  displayText: requestModel.recipient!,
                  // '${requestModel.recipient!.substring(0, 5)}...${requestModel.recipient!.substring(requestModel.recipient!.length - 5)}',
                  copyText: requestModel.recipient!,
                  crossAxisAlignment: CrossAxisAlignment.end,
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(defaultPadding * 1.5),
          width: MediaQuery.of(context).size.width,
          color: backgroundPrimaryColor.withOpacity(0.1),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (requestModel.signType.isTransaction) ...[
              Text(
                "Message",
                style: textTheme.bodyMedium,
              ),
              const Gap(defaultPadding * 1.5),
              Text(
                '${requestModel.amount ?? '0'} ${requestModel.chain?.code ?? ''}',
                style: textTheme.displayLarge,
              ),
            ] else ...[
              Text(
                "Transaction Type",
                style: textTheme.bodyMedium,
              ),
              const Gap(defaultPadding * 1.5),
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
              const Gap(defaultPadding * 2),
              Text(
                "Message",
                style: textTheme.bodyMedium,
              ),
              const Gap(defaultPadding * 1.5),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Flexible(
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    requestModel.signType == SignType.personalSign ? hexToAscii(requestModel.displayMessage) : requestModel.displayMessage,
                    style: textTheme.displayMedium,
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(
                        text: requestModel.signType == SignType.personalSign ? hexToAscii(requestModel.displayMessage) : requestModel.displayMessage,
                      ));
                    },
                    icon: Image.asset(
                      'assets/images/copyLight.png',
                      height: 24,
                    ))
              ])
            ],
          ]),
        ),
        Container(
          padding: const EdgeInsets.all(defaultPadding * 1.5),
          child: Column(
            children: [
              const Gap(defaultPadding),
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
                  padding: const EdgeInsets.all(defaultPadding * 2),
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
                            requestModel.chain?.name ?? '',
                            style: const TextStyle(
                              color: textPrimaryColor,
                              fontSize: 14,
                              height: 1.6,
                              fontFamily: 'Epilogue',
                            ),
                          ),
                        ],
                      ),
                      const Gap(defaultPadding * 2),
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
              const Gap(defaultPadding * 5),
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
      ]),
    );
  }
}

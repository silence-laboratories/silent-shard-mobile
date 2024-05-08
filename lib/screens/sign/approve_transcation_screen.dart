// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:async/async.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:silentshard/third_party/analytics.dart';

import '../../constants.dart';
import '../../repository/app_repository.dart';
import '../components/loader.dart';
import '../components/cancel.dart';
import '../components/check.dart';
import '../sign/sign_request_view_model.dart';
import '../../demo/types/demo_sign_request_view_model.dart';
import 'transaction_details_widget.dart';

enum TransactionState { readyToSign, signing, signed, canceled, failed }

class ApproveTransactionScreen extends StatefulWidget {
  final SignRequestViewModel requestModel;
  final VoidCallback resumeSignRequestSubscription;
  final String walletId;
  final String address;

  const ApproveTransactionScreen(
      {super.key, //
      required this.requestModel,
      required this.resumeSignRequestSubscription,
      required this.walletId,
      required this.address});

  @override
  State<ApproveTransactionScreen> createState() => _ApproveTransactionScreenState();
}

class _ApproveTransactionScreenState extends State<ApproveTransactionScreen> {
  CancelableOperation<String>? _signingOperation;
  TransactionState _transactionState = TransactionState.readyToSign;
  late AnalyticManager analyticManager;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 30)) //
        .then((value) {
      if (_transactionState == TransactionState.readyToSign) {
        _updateTransactionState(TransactionState.failed);
        _close();
      }
    });
    analyticManager = Provider.of<AnalyticManager>(context, listen: false);
  }

  _updateTransactionState(TransactionState value) {
    if (mounted) {
      setState(() {
        _transactionState = value;
      });
    }
  }

  Future<void> _close([bool shouldDismiss = true]) async {
    if (shouldDismiss && mounted) {
      await Future.delayed(const Duration(milliseconds: 1500));
    }
    widget.resumeSignRequestSubscription();
    if (shouldDismiss && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _onSignature(String signature) async {
    FirebaseCrashlytics.instance.log('Successfully generated signature');
    _updateTransactionState(TransactionState.signed);
    _close();
    analyticManager.trackSignPerform(status: SignPerformStatus.success);
  }

  void _onError(Object error) {
    FirebaseCrashlytics.instance.log('Error generating signature: $error');
    _updateTransactionState(TransactionState.failed);
    _close();
    analyticManager.trackSignPerform(status: SignPerformStatus.failed, error: error.toString());
  }

  void _handleSignResponse(bool approved, SignRequestViewModel requestModel, {Function? onErrorCb, bool shouldDismiss = true}) {
    if (requestModel is DemoSignRequestViewModel) return;
    final appRepository = Provider.of<AppRepository>(context, listen: false);

    if (approved) {
      FirebaseCrashlytics.instance.log('Transaction approved');
      analyticManager.trackSignPerform(status: SignPerformStatus.approved);
      _updateTransactionState(TransactionState.signing);
      _signingOperation = appRepository.approve(requestModel.signRequest);
      _signingOperation?.value.then(_onSignature, onError: (error) {
        onErrorCb?.call(error);
        _onError(error);
      });
    } else {
      FirebaseCrashlytics.instance.log('Transaction declined');
      analyticManager.trackSignPerform(status: SignPerformStatus.rejected);
      _updateTransactionState(TransactionState.canceled);
      appRepository.decline(requestModel.signRequest);
      _close(shouldDismiss);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          if (_transactionState == TransactionState.readyToSign) {
            _handleSignResponse(false, widget.requestModel, shouldDismiss: false);
          }
        }
      },
      child: SafeArea(
        child: SingleChildScrollView(
          child: Stack(children: [
            if (_transactionState == TransactionState.readyToSign)
              TransactionDetailsWidget(
                  address: widget.address, walletId: widget.walletId, requestModel: widget.requestModel, handleSignResponse: _handleSignResponse),
            if (_transactionState == TransactionState.signing || _transactionState == TransactionState.signed) ...[
              AnimatedOpacity(
                opacity: _transactionState == TransactionState.signing ? 1.0 : 0.0,
                duration: Duration(milliseconds: _transactionState == TransactionState.signing ? 0 : 500),
                child: Container(
                  alignment: Alignment.center,
                  child: const Column(children: [
                    Gap(defaultSpacing * 10),
                    Loader(text: 'Approving transaction...'),
                    Gap(defaultSpacing * 10),
                  ]),
                ),
              ),
              AnimatedOpacity(
                opacity: _transactionState == TransactionState.signed ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: const Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Gap(defaultSpacing * 10),
                      Check(text: 'Transaction Approved'),
                      Gap(defaultSpacing * 10),
                    ],
                  ),
                ),
              ),
            ],
            if (_transactionState == TransactionState.failed)
              const Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Gap(defaultSpacing * 10),
                  Cancel(text: 'Transaction Failed'),
                  Gap(defaultSpacing * 10),
                ],
              )),
            if (_transactionState == TransactionState.canceled)
              const Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Gap(defaultSpacing * 10),
                  Cancel(text: 'Transaction Canceled'),
                  Gap(defaultSpacing * 10),
                ],
              )),
          ]),
        ),
      ),
    );
  }
}

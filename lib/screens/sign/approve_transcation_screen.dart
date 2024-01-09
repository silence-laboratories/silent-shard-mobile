import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../repository/app_repository.dart';
import '../components/Loader.dart';
import '../components/cancel.dart';
import '../components/check.dart';
import '../sign/sign_request_view_model.dart';
import '../../demo/types/demo_sign_request_view_model.dart';
import 'transaction_details_widget.dart';

enum TransactionState { readyToSign, signing, signed, canceled, failed }

class ApproveTransactionScreen extends StatefulWidget {
  final SignRequestViewModel requestModel;
  final VoidCallback resumeSignRequestSubscription;

  const ApproveTransactionScreen({
    super.key,
    required this.requestModel,
    required this.resumeSignRequestSubscription,
  });

  @override
  State<ApproveTransactionScreen> createState() => _ApproveTransactionScreenState();
}

class _ApproveTransactionScreenState extends State<ApproveTransactionScreen> {
  CancelableOperation<String>? _signingOperation;
  TransactionState _transactionState = TransactionState.readyToSign;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 30)) //
        .then((value) {
      if (mounted && _transactionState == TransactionState.readyToSign) {
        _updateTransactionState(TransactionState.failed);
        _close();
      }
    });
  }

  _updateTransactionState(TransactionState value) {
    setState(() {
      _transactionState = value;
    });
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
    print("Successfully generated signature: $signature");
    _updateTransactionState(TransactionState.signed);
    _close();
  }

  void _onError(Object error) {
    print("Error generating signature: $error");
    _updateTransactionState(TransactionState.failed);
    _close();
  }

  void _handleSignResponse(bool approved, SignRequestViewModel requestModel, {Function? onErrorCb, bool shouldDismiss = true}) {
    if (requestModel is DemoSignRequestViewModel) return;
    final appRepository = Provider.of<AppRepository>(context, listen: false);

    if (approved) {
      print('Approved');
      _updateTransactionState(TransactionState.signing);
      _signingOperation = appRepository.approve(requestModel.signRequest);
      _signingOperation?.value.then(_onSignature, onError: (error) {
        onErrorCb?.call(error);
        _onError(error);
      });
    } else {
      print('Declined');
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
              TransactionDetailsWidget(requestModel: widget.requestModel, handleSignResponse: _handleSignResponse),
            if (_transactionState == TransactionState.signing || _transactionState == TransactionState.signed) ...[
              AnimatedOpacity(
                opacity: _transactionState == TransactionState.signing ? 1.0 : 0.0,
                duration: Duration(milliseconds: _transactionState == TransactionState.signing ? 0 : 500),
                child: Container(
                  alignment: Alignment.center,
                  child: const Column(children: [
                    Gap(defaultPadding * 10),
                    Loader(text: 'Approving transaction...'),
                    Gap(defaultPadding * 10),
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
                      Gap(defaultPadding * 10),
                      Check(text: 'Transaction Approved'),
                      Gap(defaultPadding * 10),
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
                  Gap(defaultPadding * 10),
                  Cancel(text: 'Transaction Failed'),
                  Gap(defaultPadding * 10),
                ],
              )),
            if (_transactionState == TransactionState.canceled)
              const Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Gap(defaultPadding * 10),
                  Cancel(text: 'Transaction Canceled'),
                  Gap(defaultPadding * 10),
                ],
              )),
          ]),
        ),
      ),
    );
  }
}

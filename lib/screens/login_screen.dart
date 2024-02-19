// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:silentshard/screens/error/error_handler.dart';
import 'package:silentshard/third_party/analytics.dart';
import 'package:silentshard/constants.dart';
import 'package:silentshard/screens/components/button.dart';
import 'package:silentshard/screens/components/loader.dart';
import '../services/sign_in_service.dart';
import '../auth_state.dart' as auth;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum AuthState { signedOut, signing, signedIn }

enum SignInType { google, apple }

class _LoginScreenState extends State<LoginScreen> {
  var _state = AuthState.signedOut;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<auth.AuthState>(context, listen: false);
    _state = authService.user != null ? AuthState.signedIn : AuthState.signedOut;
  }

  void _updateState(AuthState state) {
    setState(() {
      _state = state;
    });
  }

  Future<void> signIn(SignInType type) async {
    assert(_state == AuthState.signedOut);
    if (_state != AuthState.signedOut) return;

    try {
      _updateState(AuthState.signing);
      final signInService = Provider.of<SignInService>(context, listen: false);
      final analyticManager = Provider.of<AnalyticManager>(context, listen: false);
      switch (type) {
        case SignInType.google:
          final userCreds = await signInService.signInWithGoogle();
          analyticManager.trackSignIn(emailId: userCreds.user?.email ?? 'na', authMethod: SignInMethod.gmail);
        case SignInType.apple:
          final userCreds = await signInService.signInWithApple();
          analyticManager.trackSignIn(emailId: userCreds.user?.email ?? 'na', authMethod: SignInMethod.apple);
      }

      if (mounted) {
        _updateState(AuthState.signedIn);
      }
    } catch (error) {
      if (mounted) {
        _updateState(AuthState.signedOut);
        _showErrorScreen(context);
      }
    }
  }

  void _showErrorScreen(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ErrorHandler(
          bottomWidget: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'You can try the following to resolve this:',
              style: textTheme.bodyMedium,
            ),
            const Gap(defaultPadding),
            Text(
              '1. Check your Date & Time Settings and restore it to your local timezone.',
              style: textTheme.bodyMedium,
            ),
            const Gap(defaultPadding),
            Text(
              '2. Re-install the app and try again in some time.',
              style: textTheme.bodyMedium,
            ),
            const Gap(defaultPadding * 4),
          ]),
          onPressBottomButton: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(defaultPadding * 1.5),
            child: Column(children: [
              Expanded(child: Lottie.asset('assets/lottie/SignInScreenAnimation.json')),
              Container(
                alignment: Alignment.topLeft,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Welcome to Silent Shard', style: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const Gap(defaultPadding),
                  Text(
                    'Your distributed self custody authenticator',
                    style: textTheme.bodyMedium,
                  ),
                  const Gap(defaultPadding * 4),
                  Button(
                    onPressed: () => signIn(SignInType.google),
                    leftIcon: Image.asset(
                      'assets/images/googleIcon.png',
                      height: 30,
                      width: 22,
                    ),
                    child: Text(
                      "Sign in with Google",
                      style: textTheme.displayMedium?.copyWith(fontSize: 18),
                    ),
                  ),
                  const Gap(defaultPadding * 2),
                  if (Platform.isIOS)
                    Button(
                      onPressed: () => signIn(SignInType.apple),
                      leftIcon: const Icon(Icons.apple, color: textPrimaryColor, size: 30),
                      child: Text(
                        "Sign in with Apple",
                        style: textTheme.displayMedium?.copyWith(fontSize: 18),
                      ),
                    ),
                  if (Platform.isIOS) const Gap(defaultPadding * 2),
                  GestureDetector(
                    onTap: () {
                      final analyticManager = Provider.of<AnalyticManager>(context, listen: false);
                      ;
                      analyticManager.trackInfoSheet(PageSource.sign_in);
                      showWhyGoogleSSOModal(context, textTheme);
                    },
                    child: Text(
                      Platform.isIOS ? "Why social sign in?" : "Why Google sign in?",
                      style: textTheme.headlineSmall?.copyWith(color: primaryColor2),
                    ),
                  ),
                ]),
              )
            ]),
          ),
          if (_state == AuthState.signing)
            const AlertDialog(
              backgroundColor: secondaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              content: Wrap(children: [Loader(text: 'Signing in...')]),
            ),
        ],
      ),
    );
  }

  Future<dynamic> showWhyGoogleSSOModal(BuildContext context, TextTheme textTheme) {
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.white.withOpacity(0.15),
      showDragHandle: true,
      backgroundColor: Colors.black,
      builder: (context) => Wrap(children: [
        SafeArea(
          child: Container(
            padding: const EdgeInsets.only(left: defaultPadding * 2, right: defaultPadding * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Platform.isIOS ? "Why social sign in?" : "Why Google sign in?",
                  style: textTheme.displayMedium,
                ),
                const Gap(defaultPadding * 2),
                Text(
                  "We use your Google account ${Platform.isIOS ? 'or Apple ID' : ''} to securely link your browser and mobile device. This way, your browser can confirm it's you logging in.",
                  style: textTheme.displaySmall,
                ),
                const Gap(defaultPadding * 2),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

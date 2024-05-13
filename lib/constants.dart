// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:flutter/material.dart';

const primaryColor = Color(0xFF867DFC);
const primaryColor2 = Color(0xFFA2A3FF);
const backgroundPrimaryColor = Color(0xFF745EF6);
const backgroundPrimaryColor2 = Color(0xFF4A408D);
const backgroundSecondaryColor = Color(0xFF1A1A1A);
const backgroundSecondaryColor2 = Color(0xFF343A46);
const backgroundSecondaryColor3 = Color(0xFF3A4252);
const secondaryColor = Color(0xFF23272E);
const sheetBackgroundColor = Color(0xFF111112);

const infoColor = Color(0xFF166533);
const infoBackgroundColor = Color(0x1A4ADE80);
const warningColor = Color(0xFFFEE28A);
const warningBackgroundColor = Color(0x1AFDD147);
const errorColor = Color(0xFFF87171);
const errorBackgroundColor = Color(0xFFFECACA);
const criticalColor = Color(0xFF991B1B);
const criticalBackgroundColor = Color(0x26EF4444);

const textColor1 = Color(0xFFFFFFFF);
const textPrimaryColor = Color(0xFFF7F8F8); //textColor2
const textSecondaryColor = Color(0xFFD8DBDF); //textColor3
const textGrey = Color(0xFF8E95A2);

const pendingColor = Color(0xFFEAB308);
const doneColor = Color(0xFF4ADE80);
const doneIconColor = Color(0xFF86EFAD);

const defaultSpacing = 8.0;

const fadeInOutDuration = Duration(milliseconds: 500);

const CANNOT_VERIFY_BACKUP = 'Cannot verify backup with different address';
// TODO: Move to centralized place
const walletMetaData = {
  "metamask": {"name": "Metamask", "icon": "assets/images/metamaskIcon.png"},
  "stackup": {"name": "Stackup", "icon": "assets/images/stackup.png"},
  "biconomy": {"name": "Biconomy", "icon": "assets/images/biconomy.png"},
  "zerodev": {"name": "ZeroDev", "icon": "assets/images/zerodev.png"},
  "trustwallet": {"name": "Trust Wallet", "icon": "assets/images/trustwallet.png"},
};

class PrecachedImageKeys {
  static const String uploadRocket = 'uploadRocket';
  static const String uploadLaptop = 'uploadLaptop';
  static const String cloudUpload = 'cloudUpload';
  static const String folderOpen = 'folderOpen';
  static const String social = 'social';
}

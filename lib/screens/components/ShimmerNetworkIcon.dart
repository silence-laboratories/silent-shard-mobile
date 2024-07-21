// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../components/padded_container.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerNetworkIcon extends StatelessWidget {
  const ShimmerNetworkIcon({
    super.key,
    height,
    width,
    required this.icon,
  });

  final String icon;
  final double? height = 32;
  final double? width = 32;

  @override
  Widget build(BuildContext context) {
    return PaddedContainer(
      child: CachedNetworkImage(
          imageUrl: icon,
          height: height,
          width: width,
          placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              enabled: true,
              child: Image.asset(
                'assets/images/walletLightFill.png',
              )),
          errorWidget: (context, url, error) => Image.asset('assets/images/walletLightFill.png')),
    );
  }
}

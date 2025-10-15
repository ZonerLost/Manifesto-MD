import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CommonShimmer extends StatelessWidget {
  final double? height;
  final double? width;
  final double? radius;
  final Color baseColor;
  final Color highlightColor;

   const CommonShimmer({
    super.key,
    this.height,
    this.width,
    this.radius = 8.0,
    this.baseColor = Colors.grey,
    this.highlightColor = const Color(0xFFD6D6D6),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(radius!),
        ),
      ),
    );
  }
}
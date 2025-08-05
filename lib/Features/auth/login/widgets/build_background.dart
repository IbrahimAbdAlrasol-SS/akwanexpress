import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget buildBackground({Widget? child, double height = 350}) {
  return Stack(
    children: [
      // Blue gradient background
      Container(
        width: double.infinity,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3E7EFF),
              Color(0xFF00297A),
              // Color(0xFF16CA8B),
              // Color(0xFF109365),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.8],
          ),
        ),
      ),

      // SVG background pattern overlay
      Positioned.fill(
        child: Opacity(
          opacity: 0.3, // شفافية للنمط ليظهر مع الخلفية الزرقاء
          child: SvgPicture.asset(
            "assets/svg/bg.svg",
            fit: BoxFit.cover,
          ),
        ),
      ),

      if (child != null) child
    ],
  );
}

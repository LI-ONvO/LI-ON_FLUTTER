import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';

class AppTextStyle {
  AppTextStyle._();

  static const TextStyle baseTextStyle = TextStyle(
    fontFamily: 'HelveticaNeue',
    color: AppColors.text,
  );

  static TextStyle bold = baseTextStyle.copyWith(
    fontWeight: FontWeight.bold,
    fontSize: 24,
  );

  static TextStyle semiBold = baseTextStyle.copyWith(
    fontWeight: FontWeight.w700,
    fontSize: 20,
  );

  static TextStyle section = baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static TextStyle card = baseTextStyle.copyWith(
    fontWeight: FontWeight.w500,
    fontSize: 15,
  );

  static TextStyle button = baseTextStyle.copyWith(
    fontWeight: FontWeight.w700,
    fontSize: 14,
  );

  static TextStyle mainText = baseTextStyle.copyWith(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.subText,
  );

  static TextStyle subText = baseTextStyle.copyWith(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.subText,
  );
}

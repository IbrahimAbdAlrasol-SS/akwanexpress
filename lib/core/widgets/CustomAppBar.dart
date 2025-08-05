import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:Tosell/core/constants/spaces.dart';

class CustomAppBar extends StatelessWidget {
  final String? title;
  final EdgeInsetsGeometry? padding;
  final TextStyle? titleStyle;
  final String? subtitle;
  final String? secondSubtitle;

  final TextStyle? subTitleStyle;
  final bool showBackButton;
  final Function()? onBackButtonPressed;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? buttonWidget;
  final Widget? titleWidget;
  final Color? titleColor;

  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.secondSubtitle,
    this.showBackButton = false,
    this.onBackButtonPressed,
    this.actions,
    this.leading,
    this.buttonWidget,
    this.subTitleStyle,
    this.titleWidget,
    this.titleColor,
    this.titleStyle,
    this.padding,
  });

  @override
/*************  ✨ Windsurf Command ⭐  *************/
  /// A Custom App Bar widget to be used in the app.
  ///
  /// You can use it to create a custom app bar with a title, subtitle, and a button.
  ///
  /// The [title] parameter is the main title of the app bar.
  ///
  /// The [subtitle] parameter is the subtitle of the app bar. It can be a string or a widget.
  ///
  /// The [secondSubtitle] parameter is the second subtitle of the app bar. It can be a string or a widget.
  ///
  /// The [showBackButton] parameter is a boolean that determines whether the back button should be shown or not.
  ///
  /// The [onBackButtonPressed] parameter is a function that is called when the back button is pressed.
  ///
  /// The [actions] parameter is a list of widgets that are shown in the app bar.
  ///
  /// The [leading] parameter is a widget that is shown in the app bar.
  ///
  /// The [buttonWidget] parameter is a widget that is shown in the app bar.
  ///
  /// The [titleStyle] parameter is the style of the title.
  ///
  /// The [subTitleStyle] parameter is the style of the subtitle.
  ///
  /// The [titleWidget] parameter is a widget that is shown instead of the title.
  ///
  /// The [titleColor] parameter is the color of the title.
  ///
  /// The [padding] parameter is the padding of the app bar.
/*******  45f7e97d-b95e-4f4c-aaf6-f7a22b7c53f6  *******/ Widget build(
      BuildContext context) {
    return Container(
      padding: padding ?? AppSpaces.allMedium,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBackButton)
            GestureDetector(
              onTap: onBackButtonPressed ?? () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                alignment: Alignment.center,
                padding: AppSpaces.allSmall,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEAEEF0), width: 2),
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Icon(
                  CupertinoIcons.back,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 18.sp,
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(
                left: showBackButton ? 10 : 0,
                top: 5,
                right: showBackButton ? 10 : 0),
            child: Row(
              children: [
                if (buttonWidget != null)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpaces.medium),
                    child: buttonWidget!,
                  ),
                if (title != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? "",
                        style: titleStyle ??
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                      ),
                      if (subtitle != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subtitle ?? "",
                              style: subTitleStyle ??
                                  Theme.of(context).textTheme.titleMedium!,
                            ),
                            if (secondSubtitle != null)
                              Text(
                                secondSubtitle ?? "",
                                style: subTitleStyle ??
                                    Theme.of(context).textTheme.titleMedium!,
                              ),
                          ],
                        ),
                    ],
                  ),
                if (titleWidget != null) titleWidget!,
                if (leading != null) leading!,
              ],
            ),
          ),
          if (actions != null)
            Row(
              children: actions!,
            ),
        ],
      ),
    );
  }
}

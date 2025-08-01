import 'package:flutter/material.dart';
import 'package:Tosell/core/utils/extensions.dart';

class CustomSection extends StatefulWidget {
  final List<Widget>? children;
  final String title;
  final Color? titleColor;
  final Widget? icon;
  final Widget? leading;
  final BorderRadius? childrenRadius;
  final BorderRadius? borderRadius;
  final bool noLine;
  final bool hasDivider;

  const CustomSection({
    super.key,
    this.children,
    required this.title,
    this.icon,
    this.titleColor,
    this.childrenRadius,
    this.borderRadius,
    this.leading,
    this.hasDivider = true,
    this.noLine = false,
  });

  @override
  State<CustomSection> createState() => _CustomSectionState();
}

class _CustomSectionState extends State<CustomSection> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        // padding: const EdgeInsets.only(right: 2, left: 2, bottom: 2),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          color: context.colorScheme.outline,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 10.0, top: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textDirection: TextDirection.rtl,
                children: [
                  Row(
                    children: [
                      if (widget.icon != null) widget.icon!,
                      Padding(
                        padding: const EdgeInsets.only(top: 3, right: 7),
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                widget.titleColor ?? theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Tajawal",
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.leading != null) widget.leading!,
                ],
              ),
            ),
            if (widget.children != null && widget.children!.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius:
                      widget.childrenRadius ?? BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius:
                      widget.childrenRadius ?? BorderRadius.circular(24),
                  child: Column(
                    children: widget.children!
                        .asMap()
                        .entries
                        .map(
                          (e) => Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                ),
                                child: e.value,
                              ),
                              if (e.key != widget.children!.length - 1 &&
                                  !widget.noLine &&
                                  widget.hasDivider)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Divider(
                                    height: 1,
                                    color: theme.colorScheme.outline,
                                    thickness: 1,
                                  ),
                                ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

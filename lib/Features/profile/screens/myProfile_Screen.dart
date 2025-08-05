import 'package:Tosell/Features/home/screens/vip/vip_order_screen.dart';
import 'package:Tosell/core/Client/BaseClient.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:Tosell/core/widgets/custom_section.dart';
import 'package:Tosell/core/widgets/custom_phoneNumbrt.dart';
import 'package:Tosell/Features/profile/screens/logout_Screen.dart';
import 'package:Tosell/Features/profile/providers/profile_provider.dart';
import 'package:Tosell/Features/profile/screens/TermsAndConditions_Screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

var ProfileImage = 'assets/images/interest1.jpeg';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});
  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var profileState = ref.watch(profileNotifierProvider);
    Size size = MediaQuery.of(context).size;
    var theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: size.height * 0.06),
          child: Column(
            children: [
              profileState.when(
                data: (userInfo) => Column(
                  children: [
                    // صورة الحساب بالوسط في الأعلى
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.colorScheme.outline,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: userInfo.img != null
                                ? imageUrl + userInfo.img!
                                : '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(
                              Icons.person,
                              size: 60,
                              color: context.colorScheme.onSurface
                                  .withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Gap(AppSpaces.medium),

                    // اسم الحساب
                    Text(
                      userInfo.fullName ?? '',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Alexandria',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.0,
                        letterSpacing: 0,
                      ),
                    ),
                    const Gap(AppSpaces.small),

                    // الهاتف
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: context.colorScheme.primary,
                        ),
                        const Gap(AppSpaces.small),
                        Text(
                          customPhoneNumber(userInfo.phoneNumber ?? ''),
                          style: context.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const Gap(AppSpaces.small),

                    // العنوان
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: context.colorScheme.primary,
                        ),
                        const Gap(AppSpaces.small),
                        Text(
                          'العنوان',
                          style: context.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                error: (error, _) => Text(error.toString()),
                loading: () => const CircularProgressIndicator(),
              ),
              buildLine(size),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSection(
                    title: 'المالية',
                    icon: SvgPicture.asset(
                      "assets/svg/money-01-2.svg",
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    hasDivider: false,
                    children: [
                      Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xffF0F0F0).withOpacity(0.1),
                              border: Border.all(
                                  color: context.colorScheme.outline),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(64),
                                    color: const Color(0xffD74242),
                                  ),
                                  width: 40,
                                  height: 40,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      "assets/svg/wallet.svg",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const Gap(AppSpaces.medium),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'مستحقات في ذمة الشركة',
                                        style: context.textTheme.titleSmall!
                                            .copyWith(
                                          fontSize: 14,
                                          color: const Color(0xff8C8C8C),
                                        ),
                                      ),
                                      Text(
                                        '0 د.ع',
                                        style: context.textTheme.bodySmall!
                                            .copyWith(
                                          color: context.colorScheme.onSurface
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xffF0F0F0).withOpacity(0.1),
                              border: Border.all(
                                  color: context.colorScheme.outline),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(64),
                                    color: const Color(0xff125438),
                                  ),
                                  width: 40,
                                  height: 40,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      "assets/svg/dollar.svg",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const Gap(AppSpaces.medium),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'إجمالي أرباح المندوب',
                                        style: context.textTheme.titleSmall!
                                            .copyWith(
                                          fontSize: 14,
                                          color: const Color(0xff125438),
                                        ),
                                      ),
                                      Text(
                                        '0 د.ع',
                                        style: context.textTheme.bodySmall!
                                            .copyWith(
                                          color: context.colorScheme.onSurface
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  CustomSection(
                    title: 'الطلبات',
                    icon: SvgPicture.asset(
                      "assets/svg/box.svg",
                      color: context.colorScheme.primary,
                      width: 24,
                      height: 24,
                    ),
                    hasDivider: false,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: buildSection(
                              "قيد التوصيل",
                              subtitle: '0',
                              showBorder: false,
                              backgroundColor:
                                  const Color(0xff2A68A3).withOpacity(0.1),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              "assets/svg/delivery-truck-02.svg",
                              iconBackgroundColor: const Color(0xff2A68A3),
                              theme,
                              onTap: () {},
                            ),
                          ),
                          Expanded(
                            child: buildSection(
                              "إجمالي الطلبات",
                              subtitle: '0',
                              showBorder: false,
                              backgroundColor:
                                  Color(0xff125438).withOpacity(0.1),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              "assets/svg/box.svg",
                              iconBackgroundColor: Color(0xff125438),
                              theme,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: buildSection(
                              'إجمالي التأجيل',
                              subtitle: "0",
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              "assets/svg/CalendarBlank.svg",
                              backgroundColor:
                                  Color(0xffDDC73C).withOpacity(0.1),
                              showBorder: false,
                              iconBackgroundColor: Color(0xffDDC73C),
                              theme,
                              onTap: () {},
                            ),
                          ),
                          Expanded(
                            child: buildSection(
                              "إجمالي الإرجاع",
                              subtitle: '0',
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              "assets/svg/warning-1-svgrepo-com.svg",
                              showBorder: false,
                              backgroundColor:
                                  context.colorScheme.error.withOpacity(0.1),
                              iconBackgroundColor: const Color(0xffD74242),
                              theme,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      // إضافة "في الطريق إلى المخزن" في الأسفل
                      Expanded(
                        child: buildSection(
                          "في الطريق إلى المخزن",
                          subtitle: '0',
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          "assets/svg/",
                          showBorder: false,
                          backgroundColor:
                              const Color(0xffDDC73C).withOpacity(0.1),
                          iconBackgroundColor: const Color(0xffDDC73C),
                          theme,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),

                  // قسم الإعدادات (بدلاً من معلومات الفاتورة)
                  CustomSection(
                    title: 'الإعدادات',
                    icon: SvgPicture.asset(
                      "assets/svg/settings-01.svg",
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    childrenRadius: const BorderRadius.all(Radius.circular(16)),
                    children: [
                      Column(
                        children: [
                          // الشروط والأحكام - تحسين الحساسية
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TermsAndConditions(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: SvgPicture.asset(
                                      'assets/svg/policy.svg',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('الشروط و الأحكام'),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Divider(color: context.colorScheme.outline),
                          ),
                          // تواصل مع الدعم
                          InkWell(
                            onTap: () {
                              context.push(AppRoutes.createTicket);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: SvgPicture.asset(
                                      'assets/svg/support.svg',
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('تواصل مع الدعم'),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Divider(color: context.colorScheme.outline),
                          ),
                          // تسجيل الخروج - تحسين الحساسية
                          InkWell(
                            onTap: () => showModalBottomSheet(
                              isScrollControlled: true,
                              useRootNavigator: true,
                              context: context,
                              builder: (BuildContext context) {
                                return const LogoutScreen();
                              },
                            ),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: SvgPicture.asset(
                                      'assets/svg/logout-02.svg',
                                      color: context.colorScheme.error,
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'تسجيل الخروج',
                                    style: TextStyle(
                                      color: context.colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(AppSpaces.large),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSection(String title, String iconPath, ThemeData theme,
      {bool isRed = false,
      bool isGray = false,
      EdgeInsets? padding,
      EdgeInsets? margin,
      bool showBorder = true,
      Color? backgroundColor,
      Color? iconBackgroundColor,
      void Function()? onTap,
      String? subtitle}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ??
            const EdgeInsets.only(top: 8.0, bottom: 4, left: 16.0, right: 16.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            border: showBorder
                ? Border.all(color: theme.colorScheme.outline)
                : null,
            borderRadius: BorderRadius.circular(16),
            color: backgroundColor),
        child: CustomAppBar(
            padding: padding ?? const EdgeInsets.only(),
            title: title,
            titleStyle: context.textTheme.titleSmall!.copyWith(
              fontSize: 14,
              color: context.colorScheme.secondary,
            ),
            showBackButton: false,
            subtitle: subtitle,
            subTitleStyle: context.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w500,
            ),
            buttonWidget: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(64),
                color: iconBackgroundColor ?? const Color(0xff698596),
              ),
              width: 40,
              height: 40,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  iconPath,
                  color: Colors.white,
                ),
              ),
            )),
      ),
    );
  }

  Padding buildLine(Size size) {
    return Padding(
      padding: EdgeInsets.only(top: size.height * 0.023, bottom: 0.023),
      child: SizedBox(
        height: 1,
        width: size.width * 0.93,
        child: Container(
          color: const Color(0x0ff1f2f4),
        ),
      ),
    );
  }
}

import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
import 'package:Tosell/Features/auth/login/providers/auth_provider.dart';
import 'package:Tosell/Features/auth/login/widgets/build_background.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordNumberNamePass extends ConsumerStatefulWidget {
  const ForgotPasswordNumberNamePass({
    super.key,
  });

  @override
  ConsumerState<ForgotPasswordNumberNamePass> createState() =>
      _LoginPageState();
}

class _LoginPageState extends ConsumerState<ForgotPasswordNumberNamePass> {
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final loginState = ref.watch(authNotifierProvider);

    return loginState.when(
      data: (data) =>
          _buildUi(screenHeight, keyboardHeight, context, loginState),
      loading: () =>
          _buildUi(screenHeight, keyboardHeight, context, loginState),
      error: (error, stackTrace) => Center(
        child: Text(error.toString()),
      ),
    );
  }

  Widget _buildUi(double screenHeight, double keyboardHeight,
      BuildContext context, AsyncValue<void> loginState) {
    return Scaffold(
      body: Stack(
        children: [
          // Positioned Widget
          Column(
            children: [
              Expanded(
                child: buildBackground(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // محاذاة النصوص لليمين
                    children: [
                      const Gap(40), // إضافة مسافة لتحريك اللوجو للأسفل
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: SvgPicture.asset("assets/svg/logo-2.svg"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // DraggableScrollableSheet for the bottom section
          DraggableScrollableSheet(
            initialChildSize: 0.80, // 69% of the screen height
            minChildSize: 0.80, // Minimum 69%
            maxChildSize: 0.80, // Maximum 90%
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomAppBar(
                          padding: EdgeInsets.zero,
                          title: 'تغيير كلمة المرور',
                          showBackButton: true,
                          titleColor: Color(0xFF1A66FF),
                        ),
                        Gap(10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: CustomTextFormField(
                            // controller: passwordController,
                            radius: 16,
                            label: "كلمة المرور الجديدة",
                            obscureText: true,
                            prefixInner: Icon(
                              CupertinoIcons.lock,
                              color: context.colorScheme.primary,
                            ),
                          ),
                        ),
                        const Gap(10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: CustomTextFormField(
                            // controller: confirmPasswordController,
                            label: "تأكيد الرمز السري",
                            radius: 16,
                            obscureText: true,
                            prefixInner: Icon(
                              CupertinoIcons.lock,
                              color: context.colorScheme.primary,
                            ),
                          ),
                        ),
                        const Gap(350),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: FillButton(
                                label: "تأكيد الرمز السري",
                                // width: 415,
                                borderRadius: 16,
                                height: 50,
                                onPressed: () {
                                  context.push(AppRoutes.ForgotPasswordAuth);
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/*
                          Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(),
                            child: FillButton(
                              label: "ارسال رمز الـأكيد",
                              width: 415,
                              height: 50,
                              onPressed: () {
                                //setState(() {});
                              },
                            ),
                          ),
                        ),
*/

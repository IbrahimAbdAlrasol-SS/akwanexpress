import 'package:Tosell/core/router/app_router.dart';
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

class ForgotPasswordNum extends ConsumerStatefulWidget {
  final String PageTitle;

  const ForgotPasswordNum({super.key, required this.PageTitle});

  @override
  ConsumerState<ForgotPasswordNum> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<ForgotPasswordNum> {
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final loginState = ref.watch(authNotifierProvider);

    // loginState.when(
    //   initial: () {},
    //   loading: () {},
    //   success: (token) {
    //     context.pop();
    //     GlobalToast.show(
    //         message: "تم تسجيل الدخول بنجاح",
    //         backgroundColor: Colors.green,
    //         textColor: Colors.white);
    //     Future.microtask(() =>
    //         ref.read(userProfileControllerProvider.notifier).getUserProfile());
    //   },
    //   error: (failure) {
    //     print(failure.message);
    //   },
    // );

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
                          title: 'اكتب رقم هاتفك و سنرسل اليك رمز تحقق',
                          showBackButton: true,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 8, left: 8, top: 16),
                          child: CustomTextFormField(
                            radius: 16,
                            label: "رقم الهاتف ",
                            hint: "07xx Xxx Xxx",
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const Gap(430),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: FillButton(
                                label: "ارسال رمز الـأكيد",
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

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
                      const Gap(40), // إضافة مسافة لتحريك اللوجو للأسفل
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: SvgPicture.asset(
                            "assets/svg/logo-2.svg",
                            height: 60,
                          ),
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
                          titleColor: Color(0xFF1A66FF),
                        ),
                        Gap(10),
                        Padding(
                          padding:
                              const EdgeInsets.only(right: 8, left: 8, top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "رقم الهاتف",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const Gap(8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    // Country code with Iraqi flag
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 16),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Iraqi flag
                                          Container(
                                            width: 28,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                                width: 0.5,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              child: Stack(
                                                children: [
                                                  // Flag stripes
                                                  Column(
                                                    children: [
                                                      // Red stripe
                                                      Expanded(
                                                        child: Container(
                                                          color: const Color(
                                                              0xFFCE1126),
                                                        ),
                                                      ),
                                                      // White stripe
                                                      Expanded(
                                                        child: Container(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      // Black stripe
                                                      Expanded(
                                                        child: Container(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  // Arabic text "الله أكبر" in the center
                                                  Center(
                                                    child: Text(
                                                      'الله أكبر',
                                                      style: TextStyle(
                                                        color: const Color(
                                                            0xFF007A3D),
                                                        fontSize: 6,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const Gap(8),
                                          const Text(
                                            '+964',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const Gap(4),
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            size: 20,
                                            color: Colors.grey[600],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Phone number input
                                    Expanded(
                                      child: TextFormField(
                                        keyboardType: TextInputType.phone,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(fontSize: 16),
                                        decoration: const InputDecoration(
                                          hintText: '7xxx xxx xxx',
                                          hintStyle: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                        ),
                                        validator: (value) => value!.isEmpty
                                            ? "الرجاء إدخال رقم الهاتف"
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(440),
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

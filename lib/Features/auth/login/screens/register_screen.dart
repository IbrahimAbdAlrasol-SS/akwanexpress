// Updated Flutter UI for RegisterScreen matching the design

import 'package:Tosell/Features/home/screens/vip/delay_or_return_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
import 'package:Tosell/Features/auth/login/providers/auth_provider.dart';
import 'package:Tosell/Features/auth/login/widgets/build_background.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String selectedVehicle = 'car'; // or 'bike'

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(authNotifierProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: buildBackground(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            "assets/svg/logo-2.svg",
                            width: 120,
                            height: 40,
                          ),
                          const Gap(25),
                          const Text(
                            "جاهز تنطلق اليوم؟ نحن بانتظارك!",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const Gap(8),
                          const Text(
                            'سجّل دخولك وكن جزءًا من شبكة أكوان إكسبريس.\nتابع طلباتك، أنجز توصيلاتك، وتابع أرباحك – كل شيء في متناول يدك.',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSpaces.exLarge),
                  topRight: Radius.circular(AppSpaces.exLarge),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'انشئ حساب الآن و انتظر موافقتنا.',
                        style: context.textTheme.bodyMedium!.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      // const Gap(AppSpaces.medium),
                      CustomTextFormField(
                        controller: nameController,
                        label: "الاسم الثلاثي",
                        radius: 16,
                        prefixInner: Icon(
                          CupertinoIcons.person,
                          color: context.colorScheme.primary,
                        ),
                      ),
                      const Gap(AppSpaces.medium),
                      Text(
                        'نوع المركبة',
                        style: context.textTheme.titleMedium,
                      ),
                      const Gap(AppSpaces.exSmall),
                      _buildVehicleTypeToggle(
                        context: context,
                        selected: selectedVehicle,
                        onChanged: (val) {
                          setState(() => selectedVehicle = val);
                        },
                      ),

                      const Gap(AppSpaces.exSmall),

                      CustomTextFormField(
                        controller: phoneController,
                        radius: 16,
                        label: "رقم الهاتف",
                      ),
                      // const Gap(AppSpaces.medium),
                      CustomTextFormField(
                        controller: passwordController,
                        radius: 16,
                        label: "الرمز السري",
                        obscureText: true,
                        prefixInner: Icon(
                          CupertinoIcons.lock,
                          color: context.colorScheme.primary,
                        ),
                      ),
                      const Gap(AppSpaces.exSmall),
                      CustomTextFormField(
                        controller: confirmPasswordController,
                        label: "تأكيد الرمز السري",
                        radius: 16,
                        obscureText: true,
                        prefixInner: Icon(
                          CupertinoIcons.lock,
                          color: context.colorScheme.primary,
                        ),
                      ),
                      const Gap(AppSpaces.exSmall),
                      FillButton(
                        label: "ارسل طلب إنضمام",
                        isLoading: loginState.isLoading,
                        onPressed: () {
                          // Submit form
                        },
                      ),
                      const Gap(16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Gap(4),
                          Text('لديك حساب؟',
                              style: context.textTheme.bodyMedium),
                          const Gap(4),
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.login),
                            child: Text(
                              'تسجيل الدخول',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: context.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTypeToggle({
    required BuildContext context,
    required String selected,
    required void Function(String value) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: context.colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          _buildVehicleToggleOption(
            context: context,
            label: 'سيارة',
            value: 'car',
            selected: selected == 'car',
            onTap: () => onChanged('car'),
          ),
          Container(
            width: 1,
            height: 30,
            color: context.colorScheme.outline,
          ),
          _buildVehicleToggleOption(
            context: context,
            label: 'دراجة',
            value: 'bike',
            selected: selected == 'bike',
            onTap: () => onChanged('bike'),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleToggleOption({
    required BuildContext context,
    required String label,
    required String value,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? context.colorScheme.primary : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color:
                      selected ? context.colorScheme.primary : Colors.black54,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  String selectedVehicle = 'car';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(authNotifierProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Blue gradient background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 290, // تحديد ارتفاع الخلفية الزرقاء
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF3E7EFF),
                    Color(0xFF0056D6),
                  ],
                ),
              ),
            ),
          ),

          // Background SVG pattern
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 290,
            child: Container(
              child: SvgPicture.asset(
                "assets/svg/bg.svg",
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // Main content
          Column(
            children: [
              // Top section with logo and text
              const Gap(30),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(20),
                      // Logo with enhanced styling
                      SvgPicture.asset(
                        "assets/svg/logo-2.svg",
                        height: 60,
                      ),
                      const Gap(16),
                      // Enhanced welcome text
                      const Text(
                        "جاهز تنطلق اليوم؟ نحن بانتظارك!",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      const Text(
                        'سجّل دخولك وكن جزءًا من شبكة أكوان إكسبريس.\nتابع طلباتك، أنجز توصيلاتك، وتابع أرباحك – كل شيء في متناول يدك.',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Register Form Sheet using DraggableScrollableSheet
          DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.7,
            maxChildSize: 0.83,
            builder: (context, scrollController) {
              return Material(
                color: Colors.transparent,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 32,
                      bottom: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'انشئ حساب الآن و انتظر موافقتنا.',
                          style: context.textTheme.headlineSmall!.copyWith(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'أدخل بياناتك لإنشاء حساب جديد',
                          style: context.textTheme.bodyMedium!.copyWith(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const Gap(24),

                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                keyboardType: TextInputType.phone,
                                prefixInner: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Color(0xFFFF0000), // أحمر
                                                  Color(0xFFFFFFFF), // أبيض
                                                  Color(0xFF000000), // أسود
                                                ],
                                                stops: [0.33, 0.66, 1.0],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '+964',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 20,
                                        color: Colors.grey[600],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // const Gap(AppSpaces.medium),
                              CustomTextFormField(
                                controller: passwordController,
                                radius: 16,
                                label: "الرمز السري",
                                obscureText: !_isPasswordVisible,
                                prefixInner: Icon(
                                  CupertinoIcons.lock,
                                  color: context.colorScheme.primary,
                                ),
                                suffixInner: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                  child: Icon(
                                    _isPasswordVisible
                                        ? CupertinoIcons.eye
                                        : CupertinoIcons.eye_slash,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                hint: _isPasswordVisible
                                    ? null
                                    : "* * * * * * * *",
                              ),
                              const Gap(AppSpaces.exSmall),
                              CustomTextFormField(
                                controller: confirmPasswordController,
                                label: "تأكيد الرمز السري",
                                radius: 16,
                                obscureText: !_isConfirmPasswordVisible,
                                prefixInner: Icon(
                                  CupertinoIcons.lock,
                                  color: context.colorScheme.primary,
                                ),
                                suffixInner: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible;
                                    });
                                  },
                                  child: Icon(
                                    _isConfirmPasswordVisible
                                        ? CupertinoIcons.eye
                                        : CupertinoIcons.eye_slash,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                hint: _isConfirmPasswordVisible
                                    ? null
                                    : "* * * * * * * *",
                              ),
                              const Gap(AppSpaces.large),
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

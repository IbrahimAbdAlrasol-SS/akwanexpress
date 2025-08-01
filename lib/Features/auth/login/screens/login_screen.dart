import 'package:gap/gap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/utils/GlobalToast.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
import 'package:Tosell/core/helpers/sharedPreferencesHelper.dart';
import 'package:Tosell/Features/auth/login/providers/auth_provider.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _phoneOrUsernameController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isPasswordHidden = true;

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _phoneOrUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(authNotifierProvider);

    return loginState.when(
      data: (_) => _buildUi(context, loginState),
      loading: () => _buildUi(context, loginState),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
    );
  }

  @override
  Widget _buildUi(BuildContext context, AsyncValue<void> loginState) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Blue gradient background
            Positioned(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF034EC9),
                      Color(0xFF0056D6),
                    ],
                  ),
                ),
              ),
            ),

            // Decorative circles
            _buildDecorativeCircles(),

            // Main content
            Column(
              children: [
                // Top section with logo and text
                const Gap(50),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(1),
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

            // Login Form Sheet using DraggableScrollableSheet
            KeyboardVisibilityBuilder(
              builder: (context, isKeyboardVisible) {
                return DraggableScrollableSheet(
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
                                'سجّل دخولك وخلي توصيلاتك تنطلق.',
                                style:
                                    context.textTheme.headlineSmall!.copyWith(
                                  color: context.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                'أدخل بياناتك للوصول إلى حسابك',
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
                                    // Phone number field with country code
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        children: [
                                          // Country code section
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 16),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                    color: Colors.grey[300]!),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Iraqi flag
                                                Container(
                                                  width: 28,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3),
                                                    border: Border.all(
                                                      color: Colors.grey[300]!,
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3),
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
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            // Black stripe
                                                            Expanded(
                                                              child: Container(
                                                                color: Colors
                                                                    .black,
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
                                                                  FontWeight
                                                                      .bold,
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
                                              controller:
                                                  _phoneOrUsernameController,
                                              focusNode: _phoneFocusNode,
                                              keyboardType: TextInputType.phone,
                                              textAlign: TextAlign.right,
                                              style:
                                                  const TextStyle(fontSize: 16),
                                              decoration: const InputDecoration(
                                                hintText: '7xxx xxx xxx',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16,
                                                ),
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 16,
                                                ),
                                              ),
                                              validator: (value) => value!
                                                      .isEmpty
                                                  ? "الرجاء إدخال رقم الهاتف"
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Gap(20),
                                    // Password field with eye toggle
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        children: [
                                          // Lock icon
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 16),
                                            child: Icon(
                                              Icons.lock_outline,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              size: 24,
                                            ),
                                          ),
                                          // Password input
                                          Expanded(
                                            child: TextFormField(
                                              controller: _passwordController,
                                              focusNode: _passwordFocusNode,
                                              obscureText: _isPasswordHidden,
                                              textAlign: TextAlign.right,
                                              style:
                                                  const TextStyle(fontSize: 16),
                                              decoration: const InputDecoration(
                                                hintText: 'كلمة المرور',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16,
                                                ),
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 16,
                                                ),
                                              ),
                                              validator: (value) => value!
                                                      .isEmpty
                                                  ? "الرجاء إدخال كلمة المرور"
                                                  : null,
                                            ),
                                          ),
                                          // Eye toggle button
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 16),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isPasswordHidden =
                                                      !_isPasswordHidden;
                                                });
                                              },
                                              child: Icon(
                                                _isPasswordHidden
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: Colors.grey[600],
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Gap(16),

                                    // Forgot password link
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () => context
                                            .push(AppRoutes.ForgotPassword),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'هل نسيت كلمة السر؟',
                                          style: TextStyle(
                                            color:
                                                context.colorScheme.onSurface,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Spacer to push button to bottom
                                    SizedBox(
                                        height: isKeyboardVisible ? 20 : 60),

                                    // Login button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: loginState.isLoading
                                            ? null
                                            : () async {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  final phoneNumber =
                                                      _phoneOrUsernameController
                                                          .text;
                                                  final password =
                                                      _passwordController.text;

                                                  final result = await ref
                                                      .read(authNotifierProvider
                                                          .notifier)
                                                      .login(
                                                          passWord: password,
                                                          phonNumber:
                                                              phoneNumber);

                                                  // التحقق من نتيجة تسجيل الدخول
                                                  if (result.$1 != null) {
                                                    // تسجيل الدخول نجح
                                                    if (result.$2 ==
                                                        "ACCOUNT_PENDING_ACTIVATION") {
                                                      // الحساب في انتظار التفعيل
                                                      context.go(
                                                          '/pending-activation');
                                                    } else {
                                                      // الحساب نشط - حفظ بيانات المستخدم والانتقال للصفحة الرئيسية
                                                      SharedPreferencesHelper
                                                          .saveUser(result.$1!);
                                                      context.go(
                                                          AppRoutes.vipHome);
                                                    }
                                                  }
                                                  // في حالة الفشل، سيتم عرض الخطأ تلقائياً من خلال AsyncValue
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              context.colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: loginState.isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              )
                                            : const Text(
                                                'تسجيل الدخول',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const Gap(20),

                                    // Create account section
                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'ليس لديك حساب؟',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Gap(4),
                                          GestureDetector(
                                            onTap: () {
                                              //  context.go(AppRoutes.registerScreen);
                                            },
                                            child: Text(
                                              'إنشاء حساب',
                                              style: TextStyle(
                                                color:
                                                    context.colorScheme.primary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(
                                        height: isKeyboardVisible ? 20 : 40),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        Positioned(
          top: 150,
          left: -80,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
      ],
    );
  }
}

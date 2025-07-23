#!/bin/bash

# سكريبت لتوليد هيكلية مشروع Flutter للتطبيق
# Script to generate Flutter project structure for AkwanExpress app

echo "🚀 بدء إنشاء هيكلية مشروع AkwanExpress..."
echo "🚀 Starting AkwanExpress project structure generation..."

# إنشاء المجلدات الأساسية
# Create core directories
echo "📁 إنشاء المجلدات الأساسية..."

# Core directories
mkdir -p lib/core/constants
mkdir -p lib/core/errors
mkdir -p lib/core/helpers
mkdir -p lib/core/services
mkdir -p lib/core/theme

# Config directories
mkdir -p lib/config

# Features directories
mkdir -p lib/features/auth/{cubit,data,view,widgets}
mkdir -p lib/features/orders/{cubit,data,view,widgets}
mkdir -p lib/features/delivery_lists/{cubit,data,view,widgets}
mkdir -p lib/features/support/{cubit,data,view,widgets}
mkdir -p lib/features/wallet/{cubit,data,view,widgets}
mkdir -p lib/features/profile/{cubit,data,view,widgets}
mkdir -p lib/features/terms/{cubit,view}

echo "📄 إنشاء الملفات الأساسية..."

# ===== CORE FILES =====

# Core Constants
cat > lib/core/constants/app_constants.dart << 'EOF'
/// ثوابت التطبيق العامة
/// General app constants
class AppConstants {
  // API URLs
  static const String baseUrl = 'https://api.akwanexpress.com';
  static const String apiVersion = '/v1';
  
  // App Info
  static const String appName = 'AkwanExpress';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'app_language';
}
EOF

cat > lib/core/constants/app_colors.dart << 'EOF'
import 'package:flutter/material.dart';

/// ألوان التطبيق
/// App colors
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryDark = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFFE0B2);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF424242);
}
EOF

cat > lib/core/constants/app_strings.dart << 'EOF'
/// نصوص التطبيق
/// App strings
class AppStrings {
  // General
  static const String appName = 'أكوان إكسبريس';
  static const String loading = 'جاري التحميل...';
  static const String error = 'حدث خطأ';
  static const String retry = 'إعادة المحاولة';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';
  static const String save = 'حفظ';
  static const String edit = 'تعديل';
  static const String delete = 'حذف';
  
  // Auth
  static const String login = 'تسجيل الدخول';
  static const String register = 'إنشاء حساب';
  static const String logout = 'تسجيل الخروج';
  static const String forgotPassword = 'نسيت كلمة السر؟';
  static const String email = 'البريد الإلكتروني';
  static const String password = 'كلمة السر';
  static const String confirmPassword = 'تأكيد كلمة السر';
  static const String phone = 'رقم الهاتف';
  static const String name = 'الاسم';
  
  // Navigation
  static const String home = 'الرئيسية';
  static const String orders = 'الطلبات';
  static const String deliveryLists = 'قوائم التوصيل';
  static const String wallet = 'المحفظة';
  static const String profile = 'الملف الشخصي';
  static const String support = 'الدعم الفني';
}
EOF

# Core Errors
cat > lib/core/errors/app_exceptions.dart << 'EOF'
/// استثناءات التطبيق
/// App exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, [this.code]);
  
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([String? message]) 
      : super(message ?? 'خطأ في الاتصال بالشبكة');
}

class ServerException extends AppException {
  const ServerException([String? message]) 
      : super(message ?? 'خطأ في الخادم');
}

class AuthException extends AppException {
  const AuthException([String? message]) 
      : super(message ?? 'خطأ في المصادقة');
}

class ValidationException extends AppException {
  const ValidationException([String? message]) 
      : super(message ?? 'خطأ في التحقق من البيانات');
}
EOF

# Core Helpers
cat > lib/core/helpers/validators.dart << 'EOF'
/// مساعدات التحقق من البيانات
/// Data validation helpers
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة السر مطلوبة';
    }
    
    if (value.length < 6) {
      return 'كلمة السر يجب أن تكون 6 أحرف على الأقل';
    }
    
    return null;
  }
  
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'رقم الهاتف غير صحيح';
    }
    
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }
}
EOF

cat > lib/core/helpers/formatters.dart << 'EOF'
import 'package:intl/intl.dart';

/// مساعدات تنسيق البيانات
/// Data formatting helpers
class Formatters {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'ar_SA',
      symbol: 'ر.س',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
  
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'ar');
    return formatter.format(date);
  }
  
  static String formatTime(DateTime time) {
    final formatter = DateFormat('HH:mm', 'ar');
    return formatter.format(time);
  }
  
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'ar');
    return formatter.format(dateTime);
  }
  
  static String formatPhone(String phone) {
    // تنسيق رقم الهاتف السعودي
    if (phone.startsWith('966')) {
      return '+966 ${phone.substring(3, 5)} ${phone.substring(5, 8)} ${phone.substring(8)}';
    }
    return phone;
  }
}
EOF

# Core Services
cat > lib/core/services/location_service.dart << 'EOF'
/// خدمة الموقع الجغرافي
/// Location service
class LocationService {
  // TODO: تنفيذ خدمة الموقع الجغرافي
  // TODO: Implement location service
  
  Future<void> getCurrentLocation() async {
    // Implementation here
  }
  
  Future<void> requestLocationPermission() async {
    // Implementation here
  }
  
  Future<bool> isLocationEnabled() async {
    // Implementation here
    return false;
  }
}
EOF

cat > lib/core/services/notification_service.dart << 'EOF'
/// خدمة الإشعارات
/// Notification service
class NotificationService {
  // TODO: تنفيذ خدمة الإشعارات
  // TODO: Implement notification service
  
  Future<void> initialize() async {
    // Implementation here
  }
  
  Future<void> showNotification(String title, String body) async {
    // Implementation here
  }
  
  Future<void> requestPermission() async {
    // Implementation here
  }
}
EOF

# Core Theme
cat > lib/core/theme/app_theme.dart << 'EOF'
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// ثيم التطبيق
/// App theme
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: AppColors.primary,
      // TODO: تخصيص الثيم المظلم
      // TODO: Customize dark theme
    );
  }
}
EOF

# ===== CONFIG FILES =====

cat > lib/config/router.dart << 'EOF'
import 'package:flutter/material.dart';

/// إعدادات التوجيه
/// Router configuration
class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String orders = '/orders';
  static const String orderDetails = '/order-details';
  static const String deliveryLists = '/delivery-lists';
  static const String wallet = '/wallet';
  static const String profile = '/profile';
  static const String support = '/support';
  static const String terms = '/terms';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        // TODO: إضافة شاشة البداية
        return MaterialPageRoute(builder: (_) => const Placeholder());
      case login:
        // TODO: إضافة شاشة تسجيل الدخول
        return MaterialPageRoute(builder: (_) => const Placeholder());
      case home:
        // TODO: إضافة الشاشة الرئيسية
        return MaterialPageRoute(builder: (_) => const Placeholder());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('الصفحة غير موجودة: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
EOF

cat > lib/config/di.dart << 'EOF'
/// حقن التبعيات
/// Dependency Injection
class DependencyInjection {
  static void init() {
    // TODO: تسجيل الخدمات والكيوبت
    // TODO: Register services and cubits
    
    // Services
    // GetIt.instance.registerLazySingleton<LocationService>(() => LocationService());
    
    // Repositories
    // GetIt.instance.registerLazySingleton<AuthRepository>(() => AuthRepository());
    
    // Cubits
    // GetIt.instance.registerFactory<AuthCubit>(() => AuthCubit());
  }
}
EOF

cat > lib/config/localization.dart << 'EOF'
import 'package:flutter/material.dart';

/// إعدادات اللغة
/// Localization configuration
class AppLocalization {
  static const List<Locale> supportedLocales = [
    Locale('ar', 'SA'), // العربية
    Locale('en', 'US'), // English
  ];
  
  static const Locale defaultLocale = Locale('ar', 'SA');
  
  // TODO: إضافة ملفات الترجمة
  // TODO: Add translation files
}
EOF

# ===== FEATURE FILES =====

# Auth Feature
cat > lib/features/auth/cubit/auth_cubit.dart << 'EOF'
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

/// كيوبت المصادقة
/// Authentication cubit
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      // TODO: تنفيذ تسجيل الدخول
      // TODO: Implement login logic
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> register(String name, String email, String password, String phone) async {
    emit(AuthLoading());
    try {
      // TODO: تنفيذ إنشاء الحساب
      // TODO: Implement registration logic
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      // TODO: تنفيذ تسجيل الخروج
      // TODO: Implement logout logic
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
EOF

cat > lib/features/auth/cubit/auth_state.dart << 'EOF'
/// حالات المصادقة
/// Authentication states
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
EOF

cat > lib/features/auth/data/auth_repository.dart << 'EOF'
/// مستودع بيانات المصادقة
/// Authentication data repository
class AuthRepository {
  // TODO: تنفيذ طرق API للمصادقة
  // TODO: Implement authentication API methods
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Implementation here
    throw UnimplementedError();
  }
  
  Future<Map<String, dynamic>> register(String name, String email, String password, String phone) async {
    // Implementation here
    throw UnimplementedError();
  }
  
  Future<void> logout() async {
    // Implementation here
    throw UnimplementedError();
  }
}
EOF

cat > lib/features/auth/view/login_screen.dart << 'EOF'
import 'package:flutter/material.dart';

/// شاشة تسجيل الدخول
/// Login screen
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
      ),
      body: const Center(
        child: Text('شاشة تسجيل الدخول'),
      ),
    );
  }
}
EOF

cat > lib/features/auth/view/register_screen.dart << 'EOF'
import 'package:flutter/material.dart';

/// شاشة إنشاء الحساب
/// Registration screen
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب'),
      ),
      body: const Center(
        child: Text('شاشة إنشاء الحساب'),
      ),
    );
  }
}
EOF

cat > lib/features/auth/widgets/auth_text_field.dart << 'EOF'
import 'package:flutter/material.dart';

/// حقل نص للمصادقة
/// Authentication text field widget
class AuthTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const AuthTextField({
    super.key,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}
EOF

# Create similar structure for other features
echo "📄 إنشاء ملفات الميزات الأخرى..."

# Orders Feature
cat > lib/features/orders/cubit/orders_cubit.dart << 'EOF'
import 'package:flutter_bloc/flutter_bloc.dart';
import 'orders_state.dart';

/// كيوبت الطلبات
/// Orders cubit
class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersInitial());
  
  Future<void> loadOrders() async {
    emit(OrdersLoading());
    try {
      // TODO: تحميل الطلبات
      // TODO: Load orders
      emit(OrdersLoaded([]));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }
}
EOF

cat > lib/features/orders/cubit/orders_state.dart << 'EOF'
/// حالات الطلبات
/// Orders states
abstract class OrdersState {}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<dynamic> orders;
  OrdersLoaded(this.orders);
}

class OrdersError extends OrdersState {
  final String message;
  OrdersError(this.message);
}
EOF

cat > lib/features/orders/view/orders_screen.dart << 'EOF'
import 'package:flutter/material.dart';

/// شاشة الطلبات
/// Orders screen
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات'),
      ),
      body: const Center(
        child: Text('شاشة الطلبات'),
      ),
    );
  }
}
EOF

# Continue with other features...
# (Similar pattern for delivery_lists, support, wallet, profile, terms)

# Main.dart
cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'config/router.dart';
import 'config/di.dart';
import 'core/theme/app_theme.dart';

void main() {
  // تهيئة حقن التبعيات
  // Initialize dependency injection
  DependencyInjection.init();
  
  runApp(const AkwanExpressApp());
}

class AkwanExpressApp extends StatelessWidget {
  const AkwanExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أكوان إكسبريس',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.splash,
      // دعم اللغة العربية
      // Arabic language support
      locale: const Locale('ar', 'SA'),
      debugShowCheckedModeBanner: false,
    );
  }
}
EOF

echo "✅ تم إنشاء هيكلية المشروع بنجاح!"
echo "✅ Project structure created successfully!"

echo ""
echo "📋 الملفات المُنشأة:"
echo "📋 Created files:"
echo "   📁 lib/core/ - الأدوات المشتركة"
echo "   📁 lib/config/ - ملفات الإعدادات"
echo "   📁 lib/features/ - ميزات التطبيق"
echo "   📄 lib/main.dart - الملف الرئيسي"

echo ""
echo "🔧 الخطوات التالية:"
echo "🔧 Next steps:"
echo "   1. إضافة التبعيات المطلوبة في pubspec.yaml"
echo "   2. تنفيذ منطق الأعمال في كل ميزة"
echo "   3. إضافة واجهات المستخدم"
echo "   4. ربط API والخدمات"

echo ""
echo "🎉 مشروع AkwanExpress جاهز للتطوير!"
echo "🎉 AkwanExpress project is ready for development!"
# سكريبت PowerShell لتوليد هيكلية مشروع Flutter للتطبيق
# PowerShell script to generate Flutter project structure for AkwanExpress app

Write-Host "🚀 بدء إنشاء هيكلية مشروع AkwanExpress..." -ForegroundColor Green
Write-Host "🚀 Starting AkwanExpress project structure generation..." -ForegroundColor Green

# إنشاء المجلدات الأساسية
# Create core directories
Write-Host "📁 إنشاء المجلدات الأساسية..." -ForegroundColor Yellow

# Core directories
New-Item -ItemType Directory -Path "lib\core\constants" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\core\errors" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\core\helpers" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\core\services" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\core\theme" -Force | Out-Null

# Config directories
New-Item -ItemType Directory -Path "lib\config" -Force | Out-Null

# Features directories
New-Item -ItemType Directory -Path "lib\features\auth\cubit" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\auth\data" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\auth\view" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\auth\widgets" -Force | Out-Null

New-Item -ItemType Directory -Path "lib\features\orders\cubit" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\orders\data" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\orders\view" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\orders\widgets" -Force | Out-Null

New-Item -ItemType Directory -Path "lib\features\delivery_lists\cubit" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\delivery_lists\data" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\delivery_lists\view" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\delivery_lists\widgets" -Force | Out-Null

New-Item -ItemType Directory -Path "lib\features\support\cubit" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\support\data" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\support\view" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\support\widgets" -Force | Out-Null

New-Item -ItemType Directory -Path "lib\features\wallet\cubit" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\wallet\data" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\wallet\view" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\wallet\widgets" -Force | Out-Null

New-Item -ItemType Directory -Path "lib\features\profile\cubit" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\profile\data" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\profile\view" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\profile\widgets" -Force | Out-Null

New-Item -ItemType Directory -Path "lib\features\terms\cubit" -Force | Out-Null
New-Item -ItemType Directory -Path "lib\features\terms\view" -Force | Out-Null

Write-Host "📄 إنشاء الملفات الأساسية..." -ForegroundColor Yellow

# ===== CORE FILES =====

# Core Constants
@'
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
'@ | Out-File -FilePath "lib\core\constants\app_constants.dart" -Encoding UTF8

@'
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
'@ | Out-File -FilePath "lib\core\constants\app_colors.dart" -Encoding UTF8

@'
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
'@ | Out-File -FilePath "lib\core\constants\app_strings.dart" -Encoding UTF8

# Core Errors
@'
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
'@ | Out-File -FilePath "lib\core\errors\app_exceptions.dart" -Encoding UTF8

# Core Helpers
@'
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
'@ | Out-File -FilePath "lib\core\helpers\validators.dart" -Encoding UTF8

@'
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
'@ | Out-File -FilePath "lib\core\helpers\formatters.dart" -Encoding UTF8

# Core Services
@'
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
'@ | Out-File -FilePath "lib\core\services\location_service.dart" -Encoding UTF8

@'
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
'@ | Out-File -FilePath "lib\core\services\notification_service.dart" -Encoding UTF8

# Core Theme
@'
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
'@ | Out-File -FilePath "lib\core\theme\app_theme.dart" -Encoding UTF8

# ===== CONFIG FILES =====

@'
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
'@ | Out-File -FilePath "lib\config\router.dart" -Encoding UTF8

@'
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
'@ | Out-File -FilePath "lib\config\di.dart" -Encoding UTF8

@'
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
'@ | Out-File -FilePath "lib\config\localization.dart" -Encoding UTF8

# ===== AUTH FEATURE FILES =====

@'
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
'@ | Out-File -FilePath "lib\features\auth\cubit\auth_cubit.dart" -Encoding UTF8

@'
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
'@ | Out-File -FilePath "lib\features\auth\cubit\auth_state.dart" -Encoding UTF8

@'
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
'@ | Out-File -FilePath "lib\features\auth\data\auth_repository.dart" -Encoding UTF8

@'
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
'@ | Out-File -FilePath "lib\features\auth\view\login_screen.dart" -Encoding UTF8

@'
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
'@ | Out-File -FilePath "lib\features\auth\view\register_screen.dart" -Encoding UTF8

@'
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
'@ | Out-File -FilePath "lib\features\auth\widgets\auth_text_field.dart" -Encoding UTF8

# ===== ORDERS FEATURE FILES =====

@'
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
'@ | Out-File -FilePath "lib\features\orders\cubit\orders_cubit.dart" -Encoding UTF8

@'
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
'@ | Out-File -FilePath "lib\features\orders\cubit\orders_state.dart" -Encoding UTF8

@'
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
'@ | Out-File -FilePath "lib\features\orders\view\orders_screen.dart" -Encoding UTF8

# Create placeholder files for other features
@'
/// مستودع بيانات الطلبات
/// Orders data repository
class OrdersRepository {
  // TODO: تنفيذ طرق API للطلبات
  // TODO: Implement orders API methods
}
'@ | Out-File -FilePath "lib\features\orders\data\orders_repository.dart" -Encoding UTF8

@'
import 'package:flutter/material.dart';

/// بطاقة الطلب
/// Order card widget
class OrderCard extends StatelessWidget {
  const OrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('طلب #12345'),
        subtitle: const Text('في الطريق'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // TODO: الانتقال لتفاصيل الطلب
        },
      ),
    );
  }
}
'@ | Out-File -FilePath "lib\features\orders\widgets\order_card.dart" -Encoding UTF8

# Create similar files for other features (delivery_lists, support, wallet, profile, terms)
# For brevity, I'll create basic placeholder files

# Delivery Lists
@'
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeliveryListsState {}
class DeliveryListsInitial extends DeliveryListsState {}

class DeliveryListsCubit extends Cubit<DeliveryListsState> {
  DeliveryListsCubit() : super(DeliveryListsInitial());
}
'@ | Out-File -FilePath "lib\features\delivery_lists\cubit\delivery_lists_cubit.dart" -Encoding UTF8

@'
import 'package:flutter/material.dart';

class DeliveryListsScreen extends StatelessWidget {
  const DeliveryListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قوائم التوصيل')),
      body: const Center(child: Text('شاشة قوائم التوصيل')),
    );
  }
}
'@ | Out-File -FilePath "lib\features\delivery_lists\view\delivery_lists_screen.dart" -Encoding UTF8

# Support
@'
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SupportState {}
class SupportInitial extends SupportState {}

class SupportCubit extends Cubit<SupportState> {
  SupportCubit() : super(SupportInitial());
}
'@ | Out-File -FilePath "lib\features\support\cubit\support_cubit.dart" -Encoding UTF8

@'
import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الدعم الفني')),
      body: const Center(child: Text('شاشة الدعم الفني')),
    );
  }
}
'@ | Out-File -FilePath "lib\features\support\view\support_screen.dart" -Encoding UTF8

# Wallet
@'
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class WalletState {}
class WalletInitial extends WalletState {}

class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(WalletInitial());
}
'@ | Out-File -FilePath "lib\features\wallet\cubit\wallet_cubit.dart" -Encoding UTF8

@'
import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المحفظة')),
      body: const Center(child: Text('شاشة المحفظة')),
    );
  }
}
'@ | Out-File -FilePath "lib\features\wallet\view\wallet_screen.dart" -Encoding UTF8

# Profile
@'
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProfileState {}
class ProfileInitial extends ProfileState {}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());
}
'@ | Out-File -FilePath "lib\features\profile\cubit\profile_cubit.dart" -Encoding UTF8

@'
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: const Center(child: Text('شاشة الملف الشخصي')),
    );
  }
}
'@ | Out-File -FilePath "lib\features\profile\view\profile_screen.dart" -Encoding UTF8

# Terms
@'
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TermsState {}
class TermsInitial extends TermsState {}

class TermsCubit extends Cubit<TermsState> {
  TermsCubit() : super(TermsInitial());
}
'@ | Out-File -FilePath "lib\features\terms\cubit\terms_cubit.dart" -Encoding UTF8

@'
import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الشروط والأحكام')),
      body: const Center(child: Text('شاشة الشروط والأحكام')),
    );
  }
}
'@ | Out-File -FilePath "lib\features\terms\view\terms_screen.dart" -Encoding UTF8

# Main.dart (overwrite existing)
@'
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
'@ | Out-File -FilePath "lib\main.dart" -Encoding UTF8

Write-Host "✅ تم إنشاء هيكلية المشروع بنجاح!" -ForegroundColor Green
Write-Host "✅ Project structure created successfully!" -ForegroundColor Green

Write-Host ""
Write-Host "📋 الملفات المُنشأة:" -ForegroundColor Cyan
Write-Host "📋 Created files:" -ForegroundColor Cyan
Write-Host "   📁 lib\core\ - الأدوات المشتركة" -ForegroundColor White
Write-Host "   📁 lib\config\ - ملفات الإعدادات" -ForegroundColor White
Write-Host "   📁 lib\features\ - ميزات التطبيق" -ForegroundColor White
Write-Host "   📄 lib\main.dart - الملف الرئيسي" -ForegroundColor White

Write-Host ""
Write-Host "🔧 الخطوات التالية:" -ForegroundColor Yellow
Write-Host "🔧 Next steps:" -ForegroundColor Yellow
Write-Host "   1. إضافة التبعيات المطلوبة في pubspec.yaml" -ForegroundColor White
Write-Host "   2. تنفيذ منطق الأعمال في كل ميزة" -ForegroundColor White
Write-Host "   3. إضافة واجهات المستخدم" -ForegroundColor White
Write-Host "   4. ربط API والخدمات" -ForegroundColor White

Write-Host ""
Write-Host "🎉 مشروع AkwanExpress جاهز للتطوير!" -ForegroundColor Magenta
Write-Host "🎉 AkwanExpress project is ready for development!" -ForegroundColor Magenta
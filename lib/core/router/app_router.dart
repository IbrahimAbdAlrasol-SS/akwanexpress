import 'package:Tosell/Features/auth/login/screens/register_screen.dart';
import 'package:Tosell/Features/changeState/screens/delivery_scanner_screen.dart';
import 'package:Tosell/Features/home/screens/map_screen.dart';
import 'package:Tosell/Features/home/screens/vip/new_map_screen.dart';
import 'package:Tosell/Features/home/screens/vip/new_shipments_screen.dart';
import 'package:Tosell/Features/home/screens/vip/new_shipmetns_notification_screen.dart';
import 'package:Tosell/Features/home/screens/vip/vip_home_screen.dart';
import 'package:Tosell/Features/home/screens/vip/vip_order_screen.dart';
import 'package:Tosell/Features/notification/models/notifications.dart';
import 'package:Tosell/Features/shipments/screens/shipment/delivery_shipment_details.dart';
import 'package:Tosell/Features/shipments/screens/shipment/refound_shipment_details.dart';
import 'package:Tosell/Features/support/screens/chat/chat_screen.dart';
import 'package:Tosell/Features/support/screens/ticket_screen.dart';
import 'package:Tosell/Features/shipments/screens/shipment/pickup_shipment_details_Screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/Features/navigation.dart';
import 'package:Tosell/Features/splash/splash_screen.dart';
import 'package:Tosell/core/widgets/background_wrapper.dart';
import 'package:Tosell/Features/profile/models/transaction.dart';
import 'package:Tosell/Features/profile/screens/logout_Screen.dart';
import 'package:Tosell/Features/auth/login/screens/login_screen.dart';
import 'package:Tosell/Features/shipments/screens/shipment/shipments_screen.dart';
import 'package:Tosell/Features/profile/screens/myProfile_Screen.dart';
import 'package:Tosell/Features/order/screens/order_details_screen.dart';
import 'package:Tosell/Features/profile/screens/editProfile_Screen.dart';
import 'package:Tosell/Features/changeState/screens/scanner_screen.dart';
import 'package:Tosell/Features/profile/screens/delete_account_Screen.dart';
import 'package:Tosell/Features/profile/screens/changePassword_Screen.dart';
import 'package:Tosell/Features/notification/screens/notification_screen.dart';
import 'package:Tosell/Features/notification/screens/notification_details_screen.dart';
import 'package:Tosell/Features/notification/models/notifications.dart';
import 'package:Tosell/Features/auth/login/ForgotPassword/ForgotPasswordAuth.dart';
import 'package:Tosell/Features/auth/login/ForgotPassword/ForgotPasswordNumber.dart';
import 'package:Tosell/Features/auth/login/ForgotPassword/ForgotPasswordNumberNamePass.dart';

String initialLocation = AppRoutes.login;

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'mapNavigator');

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  navigatorKey: navigatorKey,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) =>
          const BackgroundWrapper(child: SplashScreen()),
    ),
    GoRoute(
      path: AppRoutes.deliveryScannerScreen,
      builder: (context, state) => BackgroundWrapper(
        child: DeliveryScannerScreen(
          args: state.extra as DeliveryScannerArgs,
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.scannerScreen,
      builder: (context, state) => BackgroundWrapper(
        child: ScannerScreen(
          args: (state.extra ?? ScannerArgs()) as ScannerArgs,
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const BackgroundWrapper(child: LoginPage()),
    ),

    GoRoute(
      path: AppRoutes.deleteAccount,
      builder: (context, state) =>
          const BackgroundWrapper(child: DeleteAccountScreen()),
    ),

    // TransactionDetaileScreen
    GoRoute(
      path: AppRoutes.orderDetails,
      builder: (context, state) => BackgroundWrapper(
        child: OrderDetailsScreen(
          args: state.extra as OrderDetailsArgs,
        ),
      ),
    ),

    GoRoute(
      path: AppRoutes.ForgotPassword,
      builder: (context, state) => const BackgroundWrapper(
        child: ForgotPasswordNum(
          PageTitle: 'ForgotPassword',
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.changePassword,
      builder: (context, state) => const BackgroundWrapper(
        child: ChangePasswordScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.ForgotPasswordAuth,
      builder: (context, state) => const BackgroundWrapper(
        child: ForgotPasswordAuth(),
      ),
    ),
    GoRoute(
      path: AppRoutes.ForgotpasswordnumbernamePass,
      builder: (context, state) => const BackgroundWrapper(
        child: ForgotPasswordNumberNamePass(),
      ),
    ),

    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) => BackgroundWrapper(
        child: SupportChatScreen(
          ticketId: state.extra as String,
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.logout,
      builder: (context, state) => const LogoutScreen(),
    ),

    GoRoute(
      path: AppRoutes.notificationDetails,
      builder: (context, state) => BackgroundWrapper(
        child: NotificationDetailsScreen(
          notification: state.extra as Notifications,
        ),
      ),
    ),

    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) =>
          const BackgroundWrapper(child: EditProfileScreen()),
    ),

    GoRoute(
      path: AppRoutes.vipOrder,
      builder: (context, state) => BackgroundWrapper(
          child: VipOrderScreen(
        args: state.extra as VipOrderArgs,
      )),
    ),

    // GoRoute(
    //   path: AppRoutes.orders,
    //   pageBuilder: (context, state) => CustomTransitionPage(
    //     key: state.pageKey,
    //     child: BackgroundWrapper(
    //         child: OrdersScreen(
    //       filter: state.extra as OrderFilter?,
    //     )),
    //     transitionsBuilder: _slideFromLeftTransition,
    //   ),
    // ),

    GoRoute(
      path: AppRoutes.pickupShipmentDetails,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: PickupShipmentDetailsScreen(
          shipmentId: state.extra as String,
        ),
        transitionsBuilder: _slideFromLeftTransition,
      ),
    ),
    GoRoute(
      path: AppRoutes.deliveryShipmentDetails,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: DeliveryShipmentDetails(
          shipmentId: state.extra as String,
        ),
        transitionsBuilder: _slideFromLeftTransition,
      ),
    ),
    GoRoute(
      path: AppRoutes.refoundShipmentDetails,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: RefoundShipmentDetails(
          shipmentId: state.extra as String,
        ),
        transitionsBuilder: _slideFromLeftTransition,
      ),
    ),

    GoRoute(
      path: AppRoutes.register,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const BackgroundWrapper(
          child: RegisterScreen(),
        ),
        transitionsBuilder: _slideFromLeftTransition,
      ),
    ),

    //! Shell Route for Bottom Navigation
    ShellRoute(
      builder: (context, state, child) => NavigationPage(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.notifications, //? Vip User
          builder: (context, state) =>
              const BackgroundWrapper(child: NotificationPage()),
        ),
        GoRoute(
          path: AppRoutes.ticket, //? Vip User
          builder: (context, state) => const TicketScreen(),
        ),

        GoRoute(
          path: AppRoutes.vipHome,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const VipHomeScreen(),
            transitionsBuilder: _slideFromLeftTransition,
          ),
        ),
        GoRoute(
          path: AppRoutes.shipments,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            // ignore: prefer_const_constructors
            child: BackgroundWrapper(child: const ShipmentsScreen()),
            transitionsBuilder: _slideFromLeftTransition,
          ),
        ),

        // GoRoute(
        //   path: AppRoutes.shipments,
        //   pageBuilder: (context, state) => CustomTransitionPage(
        //     key: state.pageKey,
        //     child: const BackgroundWrapper(child: NewShipmentsScreen()),
        //     transitionsBuilder: _slideFromLeftTransition,
        //   ),
        // ),
        GoRoute(
          path: AppRoutes.nearbyNotification,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const BackgroundWrapper(
                child: NewShipmentsNotificationScreen()),
            transitionsBuilder: _slideFromLeftTransition,
          ),
        ),
        GoRoute(
          path: AppRoutes.myProfile,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const BackgroundWrapper(child: MyProfileScreen()),
            transitionsBuilder: _slideFromLeftTransition,
          ),
        ),
      ],
    ),
  ],
);

/// Fade Transition
Widget _fadeTransition(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideFromLeftTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  const begin = Offset(-1.0, 0.0); // From left
  const end = Offset.zero;

  final tween = Tween(begin: begin, end: end)
      .chain(CurveTween(curve: Curves.fastLinearToSlowEaseIn));

  return SlideTransition(
    position: animation.drive(tween),
    child: child,
  );
}

class AppRoutes {
  static const String splash = '/';
  static const String notifications = '/notifications';
  static const String notificationDetails = '/notification-details';
  static const String chats = '/chats';
  static const String register = '/register';
  static const String chat = '/chat';
  static const String orderDetails = '/order-details';
  // static const String home = '/home';
  static const String vipHome = '/vip_home';
  // static const String map = '/map';
  // static const String orders = '/orders';
  static const String myProfile = '/my_profile';
  static const String editProfile = '/edit_profile';
  static const String vipOrder = '/vip_order';
  static const String selectLocation = '/select_location';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String background = '/background';
  static const String deliveryScannerScreen = '/deliveryScannerScreen';
  static const String scannerScreen = '/scannerScreen';
  static const String changePassword = '/changePassword';
  static const String deleteAccount = '/deleteAccount';
  static const String shipments = '/shipments';
  static const String pickupShipmentDetails = '/pickupShipmentDetails';
  static const String deliveryShipmentDetails = '/deliveryShipmentDetails';
  static const String refoundShipmentDetails = '/refoundShipmentDetails';
  static const String nearbyNotification = '/nearbyNotification';

  static const String ticket = '/ticket';

  static const String ForgotPassword = '/ForgotPasswordNum';
  static const String ForgotPasswordAuth = '/ForgotpasswordAuth';
  static const String ForgotpasswordnumbernamePass =
      '/ForgotPasswordNumberNamePass';
}

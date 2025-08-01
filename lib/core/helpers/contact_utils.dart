import 'package:Tosell/Features/home/models/shipment_in_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Tosell/core/utils/extensions.dart';

class ContactUtils {
  /// Launch WhatsApp with a phone number
  static Future<void> openWhatsApp(String phoneNumber) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final formatted = cleaned.startsWith('964') ? cleaned : '964$cleaned';

    final url = Uri.parse("https://wa.me/$formatted");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch WhatsApp');
    }
  }

  /// Launch a call
  static Future<void> makeCall(String phoneNumber) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final formatted = cleaned.startsWith('964') ? cleaned : '964$cleaned';

    final uri = Uri.parse('tel:+$formatted');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Launch an SMS
  static Future<void> sendSMS(String phoneNumber) async {
    final uri = Uri.parse('sms:${_sanitize(phoneNumber)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Open location in Waze
  static Future<void> openInWaze(Location location) async {
    try {
      print(
          '🗺️ محاولة فتح Waze مع الإحداثيات: ${location.lat}, ${location.long}');

      // Try Waze app first
      final appUri =
          Uri.parse('waze://?ll=${location.lat},${location.long}&navigate=yes');
      print('🔗 محاولة فتح تطبيق Waze: $appUri');

      if (await canLaunchUrl(appUri)) {
        print('✅ تطبيق Waze متاح، جاري الفتح...');
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Try Waze website as fallback
      final webUri = Uri.parse(
          'https://waze.com/ul?ll=${location.lat},${location.long}&navigate=yes');
      print('🌐 محاولة فتح موقع Waze: $webUri');

      if (await canLaunchUrl(webUri)) {
        print('✅ موقع Waze متاح، جاري الفتح...');
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Try Google Maps as last resort
      final googleMapsUri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=${location.lat},${location.long}');
      print('🗺️ محاولة فتح Google Maps: $googleMapsUri');

      if (await canLaunchUrl(googleMapsUri)) {
        print('✅ Google Maps متاح، جاري الفتح...');
        await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
        return;
      }

      print('❌ فشل في فتح أي تطبيق خرائط');
      throw Exception('Could not launch any map application');
    } catch (e) {
      print('❌ خطأ في فتح Waze: $e');
      rethrow;
    }
  }

  /// Show modal for contact options
  static void showContactOptions(BuildContext context, String phoneNumber) {
    final sanitized = _sanitize(phoneNumber);
    if (!_isValidIraqiPhone(sanitized)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم الهاتف غير صالح')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: SvgPicture.asset(
              'assets/svg/social-whats-app-svgrepo-com.svg',
              color: context.colorScheme.primary,
              width: 24,
              height: 24,
            ),
            title: const Text('WhatsApp'),
            onTap: () {
              Navigator.pop(context);
              openWhatsApp(sanitized);
            },
          ),
          ListTile(
            leading: Icon(Icons.phone, color: context.colorScheme.primary),
            title: const Text('Call'),
            onTap: () {
              Navigator.pop(context);
              makeCall(sanitized);
            },
          ),
          ListTile(
            leading: Icon(Icons.message, color: context.colorScheme.primary),
            title: const Text('SMS'),
            onTap: () {
              Navigator.pop(context);
              sendSMS(sanitized);
            },
          ),
        ],
      ),
    );
  }

  static String _sanitize(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  static bool _isValidIraqiPhone(String phone) {
    final cleaned = phone.startsWith('964') ? phone.substring(3) : phone;
    const iraqiPrefixes = [
      '770',
      '771',
      '772',
      '773',
      '774',
      '750',
      '751',
      '752',
      '780',
      '781',
      '782',
      '783',
    ];
    return cleaned.length == 10 &&
        iraqiPrefixes.contains(cleaned.substring(0, 3));
  }
}


/// مسارات الصور - AkwanExpress
/// App images paths - AkwanExpress
class AppImages {
  // ===== BASE PATH =====
  static const String _basePath = 'assets/images/';
  
  // ===== ALERTS & NOTIFICATIONS =====
  static const String alert02 = '${_basePath}alert-02.svg';
  static const String notification = '${_basePath}notification-.svg';
  
  // ===== ARROWS & NAVIGATION =====
  static const String arrow = '${_basePath}arrow.svg';
  
  // ===== CAMERA & MEDIA =====
  static const String cameraAdd01 = '${_basePath}camera-add-01.svg';
  static const String view = '${_basePath}view.svg';
  
  // ===== VEHICLES & DELIVERY =====
  static const String carAlert = '${_basePath}car-alert.svg';
  static const String carSignal = '${_basePath}car-signal.svg';
  static const String deliveryTruck02 = '${_basePath}delivery-truck-02.svg';
  
  // ===== TIME & CLOCK =====
  static const String clock03 = '${_basePath}clock-03.svg';
  
  // ===== SUPPORT & CUSTOMER SERVICE =====
  static const String customerSupport = '${_basePath}customer-support.svg';
  
  // ===== ACTIONS =====
  static const String delete = '${_basePath}delete.svg';
  static const String tick04 = '${_basePath}tick-04.svg';
  
  // ===== FILES & DOCUMENTS =====
  static const String files01 = '${_basePath}files-01.svg';
  
  // ===== LOCATION & MAPS =====
  static const String location = '${_basePath}location.svg';
  static const String mapsCircle = '${_basePath}maps-circle.svg';
  static const String waze = '${_basePath}waze.svg';
  
  // ===== SECURITY =====
  static const String lockPassword = '${_basePath}lock-password.svg';
  static const String smsCode = '${_basePath}sms-code.svg';
  
  // ===== BRANDING =====
  static const String logo = '${_basePath}logo.svg';
  
  // ===== PACKAGES & ORDERS =====
  static const String packageDelivered = '${_basePath}package-delivered.svg';
  static const String packageMoving = '${_basePath}package-moving.svg';
  static const String packageOutOfStock = '${_basePath}package-out-of-stock.svg';
  static const String packageProcess = '${_basePath}package-process.svg';
  
  // ===== STORES & MERCHANTS =====
  static const String store01 = '${_basePath}store-01.svg';
  static const String storeVerified = '${_basePath}store-verified.svg';
  static const String warehouse = '${_basePath}warehouse.svg';
  
  // ===== USER & PROFILE =====
  static const String user = '${_basePath}user.svg';
  static const String userSettings = '${_basePath}user-settings.svg';
  
  // ===== FLAGS & COUNTRIES =====
  static const String iraqFlag = '${_basePath}🇮🇶.svg';
  
  // ===== HELPER METHODS =====
  
  /// الحصول على مسار الصورة الكامل
  /// Get full image path
  static String getImagePath(String imageName) {
    return '$_basePath$imageName';
  }
  
  /// التحقق من وجود امتداد SVG
  /// Check if image has SVG extension
  static String ensureSvgExtension(String imageName) {
    if (!imageName.endsWith('.svg')) {
      return '$imageName.svg';
    }
    return imageName;
  }
  
  /// الحصول على مسار الصورة مع ضمان امتداد SVG
  /// Get image path with ensured SVG extension
  static String getSvgPath(String imageName) {
    final svgName = ensureSvgExtension(imageName);
    return getImagePath(svgName);
  }
}
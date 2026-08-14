class AppConstants {
  AppConstants._();

  static const String appName     = 'Nông sản Việt';
  static const String appSubtitle = 'Ứng dụng Điều phối và Tiêu thụ Nông sản Trực tiếp';
  static const String appVersion  = '1.0.0';

  // Firestore collections
  static const String usersCol         = 'users';
  static const String lotsCol          = 'lots';
  static const String ordersCol        = 'orders';
  static const String offersCol        = 'offers';
  static const String notificationsCol = 'notifications';

  // Pagination
  static const int pageSize = 20;

  // Pricing
  static const double baseShipFee    = 1850000;
  static const double freeShipMinKg  = 2000;
}

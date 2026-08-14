// File này được tạo tự động từ google-services.json
// Tương đương với kết quả của lệnh: flutterfire configure
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web không được hỗ trợ trong project này.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS chưa cấu hình.');
      default:
        throw UnsupportedError('Platform không được hỗ trợ: $defaultTargetPlatform');
    }
  }

  // Lấy từ google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'AIzaSyC6JnyljMs9KAMBupEJw1KibrMr9cUwdVw',
    appId:             '1:950777736871:android:66f2fd85d67fd7609b7582',
    messagingSenderId: '950777736871',
    projectId:         'nongsanapp-fda5b',
    storageBucket:     'nongsanapp-fda5b.firebasestorage.app',
  );
}

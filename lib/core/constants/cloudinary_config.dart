/// Cấu hình Cloudinary — thay 3 giá trị dưới đây bằng thông tin của bạn
/// Lấy tại: cloudinary.com → Dashboard
class CloudinaryConfig {
  CloudinaryConfig._();

  static const String cloudName    = 'nqg8gf74';   // ✅ Cloud Name của nhóm
  static const String uploadPreset = 'nongsanapp';  // preset unsigned đã tạo

  // URL upload endpoint
  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  // URL xem ảnh (tự động tối ưu kích thước)
  static String thumbnailUrl(String publicId, {int width = 400}) =>
      'https://res.cloudinary.com/$cloudName/image/upload/w_$width,c_fill,f_auto,q_auto/$publicId';
}

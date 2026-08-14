import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../../../core/constants/cloudinary_config.dart';
import '../../../core/utils/formatters.dart';

/// Service upload ảnh lên Cloudinary — MIỄN PHÍ, không cần Firebase Storage
///
/// Cách dùng:
///   final service = CloudinaryService();
///   final url = await service.uploadImage(file: imageFile, folder: 'products');
class CloudinaryService {
  final _picker = ImagePicker();

  // ── Upload 1 ảnh ────────────────────────────────────────────────────
  Future<String?> uploadImage({
    required File file,
    String folder = 'nongsanapp',
  }) async {
    try {
      final publicId = '${folder}_${const Uuid().v4()}';

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(CloudinaryConfig.uploadUrl),
      );

      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
      request.fields['public_id']     = publicId;
      request.fields['folder']        = folder;

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      final response = await request.send();
      final body     = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final json = jsonDecode(body) as Map<String, dynamic>;
        return json['secure_url'] as String?;
      } else {
        _log('Upload lỗi: $body');
        return null;
      }
    } catch (e) {
      _log('uploadImage lỗi: $e');
      return null;
    }
  }

  // ── Upload nhiều ảnh cùng lúc ────────────────────────────────────────
  Future<List<String>> uploadMultipleImages({
    required List<File> files,
    String folder = 'products',
  }) async {
    final List<String> urls = [];
    for (final file in files) {
      final url = await uploadImage(file: file, folder: folder);
      if (url != null) urls.add(url);
    }
    return urls;
  }

  // ── Chọn ảnh từ gallery ──────────────────────────────────────────────
  Future<File?> pickFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,   // giảm dung lượng
      maxWidth: 1200,
    );
    return picked != null ? File(picked.path) : null;
  }

  // ── Chụp ảnh bằng camera ─────────────────────────────────────────────
  Future<File?> pickFromCamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1200,
    );
    return picked != null ? File(picked.path) : null;
  }

  // ── Chọn nhiều ảnh ───────────────────────────────────────────────────
  Future<List<File>> pickMultipleImages({int max = 5}) async {
    final picked = await _picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1200,
    );
    return picked.take(max).map((x) => File(x.path)).toList();
  }
}

// ignore: avoid_print
void _log(String msg) => print('[CloudinaryService] $msg');

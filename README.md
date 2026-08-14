# 🌿 Nông sản Việt — Ứng dụng Điều phối và Tiêu thụ Nông sản Trực tiếp

**Học phần:** CSE441 – Phát triển ứng dụng cho thiết bị di động  
**Trường:** Đại học Thủy lợi – Khoa Công nghệ Thông tin  
**Nhóm:** 07

---

## 👥 Thành viên nhóm

| STT | Mã SV | Họ và Tên | Vai trò |
|:---:|:---:|:---|:---|
| 1 | 2251172268 | Dương Tiến Đạt | Trưởng nhóm / HTX Module / UI |
| 2 | 2251061886 | Phạm Ngọc Thành | Buyer Module / Data / Integration |

---

## 📱 Giới thiệu

Ứng dụng kết nối trực tiếp **Hợp tác xã/Nhà vườn** với **Siêu thị, Nhà hàng, Đơn vị thu mua** số lượng lớn, loại bỏ các tầng trung gian không cần thiết.

### Tính năng chính:
- 🌾 HTX đăng bán lô nông sản, quản lý đơn hàng, tồn kho
- 🛒 Người mua tìm kiếm, đặt hàng, gửi đề nghị giá
- 📦 Theo dõi trạng thái đơn hàng realtime
- 🔔 Thông báo FCM khi có đơn mới / cập nhật trạng thái
- 📸 Upload ảnh qua Cloudinary (miễn phí)

---

## 🛠️ Công nghệ sử dụng

| Công nghệ | Mục đích |
|:---|:---|
| Flutter 3.44 / Dart | Framework ứng dụng di động |
| Firebase Auth | Xác thực người dùng |
| Cloud Firestore | Database realtime |
| Firebase FCM | Push notification |
| Cloudinary | Lưu trữ ảnh |
| Riverpod 2.x | State Management |
| GoRouter | Navigation |

---

## 🚀 Cài đặt và chạy

```bash
# 1. Clone repo
git clone https://github.com/DuongTienDat3011/Moblie-app.git
cd Moblie-app

# 2. Cài dependencies
flutter pub get

# 3. Cấu hình Firebase
# - Tạo project Firebase tại console.firebase.google.com
# - Thêm android/app/google-services.json
# - Chạy: flutterfire configure

# 4. Cấu hình Cloudinary
# - Sửa lib/core/constants/cloudinary_config.dart

# 5. Chạy ứng dụng
flutter run
```

---

## 📁 Cấu trúc thư mục

```
lib/
├── core/           # Theme, enums, constants, utils
├── data/           # Models, Repositories, Datasources
├── domain/         # Abstract interfaces
├── providers/      # Riverpod providers (DI)
├── presentation/
│   ├── auth/       # Login, Register, Forgot
│   ├── htx/        # Dashboard, Lô hàng, Đơn hàng, Tồn kho
│   ├── buyer/      # Home, Tìm kiếm, Đặt hàng, Đơn hàng
│   └── shared/     # Shared widgets
├── routing/        # GoRouter config
└── main.dart
```

---

## 🌿 Nhóm 07 – CSE441 – Đại học Thủy lợi 2025-2026

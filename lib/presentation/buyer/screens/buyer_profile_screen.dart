import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/firebase_providers.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';

class BuyerProfileScreen extends ConsumerWidget {
  const BuyerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tài khoản')),
      body: userAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Chưa đăng nhập'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Avatar + tên ────────────────────────────────────────
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.lightGreen,
                    child: Text(
                      (user.displayName.isNotEmpty
                          ? user.displayName[0]
                          : 'B').toUpperCase(),
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.orgName ?? user.displayName,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 3),
                      Text(user.email,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.blueSurface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Đơn vị thu mua',
                          style: TextStyle(fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blue)),
                      ),
                    ],
                  )),
                ]),
              ),
              const SizedBox(height: 16),

              // ── Thông tin ─────────────────────────────────────────
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(children: [
                  _infoTile(Icons.person_outline, 'Họ tên',
                      user.displayName),
                  _divider(),
                  _infoTile(Icons.phone_outlined, 'Số điện thoại',
                      user.phone.isEmpty ? 'Chưa cập nhật' : user.phone),
                  _divider(),
                  _infoTile(Icons.email_outlined, 'Email', user.email),
                ]),
              ),
              const SizedBox(height: 16),

              // ── Menu ─────────────────────────────────────────────
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(children: [
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined,
                        color: AppColors.primaryGreen),
                    title: const Text('Đơn hàng của tôi',
                        style: TextStyle(fontSize: 14.5)),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textHint),
                    onTap: () {
                      // Chuyển tab đơn hàng (index 2 trong BuyerShell)
                      // Dùng go để navigate về buyer và switch tab
                      context.go('/buyer');
                    },
                  ),
                  const Divider(height: 1, indent: 52),
                  ListTile(
                    leading: const Icon(Icons.favorite_border_rounded,
                        color: AppColors.primaryGreen),
                    title: const Text('Sản phẩm yêu thích',
                        style: TextStyle(fontSize: 14.5)),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textHint),
                    onTap: () => context.push('/buyer/search'),
                  ),
                  const Divider(height: 1, indent: 52),
                  ListTile(
                    leading: const Icon(Icons.search_outlined,
                        color: AppColors.primaryGreen),
                    title: const Text('Tìm kiếm nông sản',
                        style: TextStyle(fontSize: 14.5)),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textHint),
                    onTap: () => context.push('/buyer/search'),
                  ),
                  const Divider(height: 1, indent: 52),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded,
                        color: AppColors.textSecondary),
                    title: const Text('Hỗ trợ',
                        style: TextStyle(fontSize: 14.5)),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textHint),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Hỗ trợ'),
                          content: const Text(
                              'Liên hệ hỗ trợ qua email: support@nongsanviet.vn\n'
                              'Hotline: 1800 xxxx (miễn phí)'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Đóng')),
                          ],
                        ),
                      );
                    },
                  ),
                ]),
              ),
              const SizedBox(height: 24),

              AppButton(
                label: 'Đăng xuất',
                variant: AppButtonVariant.destructive,
                icon: Icons.logout_rounded,
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Đăng xuất?'),
                      content: const Text(
                          'Bạn có chắc muốn đăng xuất không?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Hủy')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Đăng xuất')),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(firebaseAuthProvider).signOut();
                    if (context.mounted) context.go('/login');
                  }
                },
              ),
              const SizedBox(height: 12),
              const Text('Nông sản Việt · Phiên bản 1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: AppColors.textHint)),
            ],
          );
        },
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(
            fontSize: 13.5, color: AppColors.textSecondary)),
        const Spacer(),
        Flexible(child: Text(value,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500),
          textAlign: TextAlign.right,
          maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
    );

  Widget _divider() =>
      const Divider(height: 1, color: Color(0xFFF0F2F0));
}

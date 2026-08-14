import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/datasources/local/saved_credentials_service.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_field.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl    = TextEditingController();
  bool _remember   = true;
  bool _isLoading  = true; // true khi đang load saved credentials
  int  _roleIndex  = 0;    // 0=HTX, 1=Buyer

  static const _roles = [
    _RoleOption('Nhà cung cấp', Icons.eco_rounded,
        'Hợp tác xã / Nhà vườn — đăng lô và quản lý nông sản'),
    _RoleOption('Đơn vị thu mua', Icons.shopping_bag_outlined,
        'Siêu thị, nhà hàng, bếp ăn — tìm và đặt mua nông sản'),
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  /// Load thông tin đã lưu khi mở màn hình
  Future<void> _loadSavedCredentials() async {
    final remembered = await SavedCredentialsService.isRemembered();
    if (remembered) {
      final email    = await SavedCredentialsService.getSavedEmail();
      final password = await SavedCredentialsService.getSavedPassword();
      final role     = await SavedCredentialsService.getSavedRoleIndex();
      if (mounted) {
        setState(() {
          if (email    != null) _emailCtrl.text = email;
          if (password != null) _pwCtrl.text    = password;
          _remember   = true;
          _roleIndex  = role;
          _isLoading  = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // Lưu hoặc xóa credentials tùy theo checkbox
    if (_remember) {
      await SavedCredentialsService.save(
        email:     _emailCtrl.text.trim(),
        password:  _pwCtrl.text,
        roleIndex: _roleIndex,
      );
    } else {
      await SavedCredentialsService.clear();
    }

    await ref.read(authNotifierProvider.notifier).login(
      email:    _emailCtrl.text.trim(),
      password: _pwCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: AppColors.red));
        ref.read(authNotifierProvider.notifier).clearError();
      }

      if (next.success) {
        // Navigate theo role thực từ Firestore
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          ref.invalidate(currentUserProvider);
          await Future.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;
          final user = ref.read(currentUserProvider).value;
          if (user != null && user.role.name == 'htx') {
            context.go('/htx');
          } else {
            context.go('/buyer');
          }
        });
      }
    });

    final auth = ref.watch(authNotifierProvider);

    // Hiện loading khi đang đọc SharedPreferences
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.lightGreen,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Logo ────────────────────────────────────────────────
                Center(child: Column(children: [
                  Container(
                    width: 68, height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(
                        color: AppColors.primaryGreen.withAlpha(46),
                        blurRadius: 24, offset: const Offset(0, 8))],
                    ),
                    child: const Icon(Icons.eco_rounded,
                        size: 40, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 12),
                  const Text('Nông sản Trực tiếp',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                        color: AppColors.darkGreen)),
                  const SizedBox(height: 4),
                  const Text(AppConstants.appSubtitle,
                    style: TextStyle(fontSize: 12,
                        color: AppColors.textSecondary),
                    textAlign: TextAlign.center),
                ])),
                const SizedBox(height: 28),

                // ── Chọn vai trò ────────────────────────────────────────
                const Text('Đăng nhập với vai trò',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                Row(
                  children: _roles.asMap().entries.map((e) {
                    final on = e.key == _roleIndex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _roleIndex = e.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: EdgeInsets.only(right: e.key == 0 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: on ? AppColors.lightGreen : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: on
                                  ? AppColors.primaryGreen : AppColors.divider,
                              width: on ? 2 : 1),
                          ),
                          child: Column(children: [
                            Icon(e.value.icon, size: 22,
                              color: on
                                  ? AppColors.primaryGreen : AppColors.textHint),
                            const SizedBox(height: 4),
                            Text(e.value.label,
                              style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600,
                                color: on
                                    ? AppColors.darkGreen
                                    : AppColors.textSecondary)),
                          ]),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 6),
                Text(_roles[_roleIndex].desc,
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.textSecondary,
                      height: 1.4)),
                const SizedBox(height: 20),

                // ── Email ───────────────────────────────────────────────
                AppField(
                  label: 'Email hoặc số điện thoại',
                  controller: _emailCtrl,
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Vui lòng nhập email' : null,
                ),
                const SizedBox(height: 14),

                // ── Mật khẩu ────────────────────────────────────────────
                AppField(
                  label: 'Mật khẩu',
                  controller: _pwCtrl,
                  prefixIcon: Icons.shield_outlined,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Mật khẩu tối thiểu 6 ký tự' : null,
                ),
                const SizedBox(height: 12),

                // ── Ghi nhớ + Quên mật khẩu ─────────────────────────────
                Row(children: [
                  // Checkbox ghi nhớ
                  GestureDetector(
                    onTap: () async {
                      setState(() => _remember = !_remember);
                      // Nếu bỏ tick → xóa ngay credentials đã lưu
                      if (!_remember) {
                        await SavedCredentialsService.clear();
                      }
                    },
                    child: Row(children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: _remember
                              ? AppColors.primaryGreen : Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: _remember
                                ? AppColors.primaryGreen : AppColors.divider,
                            width: 2),
                        ),
                        child: _remember
                            ? const Icon(Icons.check, size: 13,
                                color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      const Text('Ghi nhớ đăng nhập',
                        style: TextStyle(fontSize: 13.5,
                            color: AppColors.textPrimary)),
                    ]),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.push('/forgot'),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text('Quên mật khẩu?',
                      style: TextStyle(fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen)),
                  ),
                ]),

                // ── Thông báo nhỏ khi có thông tin đã lưu ──────────────
                if (_remember && _emailCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline_rounded, size: 16,
                          color: AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      Expanded(child: Text(
                        'Đăng nhập nhanh với tài khoản đã lưu: '
                        '${_emailCtrl.text}',
                        style: const TextStyle(fontSize: 12,
                            color: AppColors.darkGreen, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis)),
                    ]),
                  ),
                ],
                const SizedBox(height: 20),

                // ── Nút đăng nhập ───────────────────────────────────────
                AppButton(
                  label: 'Đăng nhập',
                  onPressed: _login,
                  isLoading: auth.isLoading,
                  icon: Icons.login_rounded,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Đăng ký tài khoản',
                  variant: AppButtonVariant.outline,
                  onPressed: () => context.push('/register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleOption {
  final String label;
  final IconData icon;
  final String desc;
  const _RoleOption(this.label, this.icon, this.desc);
}

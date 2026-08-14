import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_field.dart';
import '../../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _key         = GlobalKey<FormState>();
  final _orgCtrl     = TextEditingController();
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _pwCtrl      = TextEditingController();
  final _pw2Ctrl     = TextEditingController();
  UserRole _role     = UserRole.htx;
  bool _agree        = false;
  int  _step         = 1;

  @override
  void dispose() {
    for (final c in [_orgCtrl, _nameCtrl, _phoneCtrl,
        _emailCtrl, _pwCtrl, _pw2Ctrl]) c.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_key.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đồng ý điều khoản sử dụng')));
      return;
    }
    await ref.read(authNotifierProvider.notifier).register(
      email:       _emailCtrl.text.trim(),
      password:    _pwCtrl.text,
      displayName: _nameCtrl.text.trim(),
      phone:       _phoneCtrl.text.trim(),
      orgName:     _orgCtrl.text.trim(),
      role:        _role,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!),
              backgroundColor: AppColors.red));
        ref.read(authNotifierProvider.notifier).clearError();
      }
      if (next.success) {
        // Đăng ký thành công → thông báo đơn giản, không có "duyệt hồ sơ"
        showDialog(
          context: context, barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 60, height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.lightGreen, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 32,
                    color: AppColors.primaryGreen)),
              const SizedBox(height: 16),
              const Text('Tạo tài khoản thành công!',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
              const SizedBox(height: 10),
              const Text(
                'Tài khoản của bạn đã sẵn sàng. Đăng nhập để bắt đầu sử dụng.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5,
                    color: AppColors.textSecondary, height: 1.4)),
            ]),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/login');
                  },
                  child: const Text('Đăng nhập ngay')),
              ),
            ],
          ),
        );
      }
    });

    final auth = ref.watch(authNotifierProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Đăng ký · Bước $_step/2',
              style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w600)),
            Text(
              _role == UserRole.htx ? 'Nhà cung cấp' : 'Đơn vị thu mua',
              style: const TextStyle(fontSize: 12,
                  color: AppColors.textSecondary)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20,
              color: AppColors.textPrimary),
          onPressed: () =>
              _step == 1 ? context.pop() : setState(() => _step = 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step bar
                Row(children: [1, 2].map((s) => Expanded(child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: s < 2 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: s <= _step
                        ? AppColors.primaryGreen : AppColors.divider,
                    borderRadius: BorderRadius.circular(2)),
                ))).toList()),
                const SizedBox(height: 20),

                if (_step == 1) ..._buildStep1()
                else ..._buildStep2(auth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStep1() => [
    // Chọn role
    const Text('Chọn loại tài khoản',
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
          color: AppColors.textSecondary)),
    const SizedBox(height: 10),
    Row(children: [
      _roleChip(UserRole.htx, 'Nhà cung cấp',
          Icons.eco_rounded, 'Hợp tác xã, nhà vườn'),
      const SizedBox(width: 10),
      _roleChip(UserRole.buyer, 'Đơn vị thu mua',
          Icons.shopping_bag_outlined, 'Siêu thị, nhà hàng'),
    ]),
    const SizedBox(height: 16),

    AppField(
      label: _role == UserRole.htx
          ? 'Tên hợp tác xã / nhà vườn'
          : 'Tên doanh nghiệp / đơn vị',
      controller: _orgCtrl, required: true,
      prefixIcon: Icons.home_outlined,
      validator: (v) => (v == null || v.trim().isEmpty)
          ? 'Vui lòng điền tên' : null),
    const SizedBox(height: 12),

    AppField(
      label: _role == UserRole.htx
          ? 'Người đại diện' : 'Người phụ trách',
      controller: _nameCtrl, required: true,
      prefixIcon: Icons.person_outline,
      validator: (v) => (v == null || v.trim().isEmpty)
          ? 'Vui lòng điền họ tên' : null),
    const SizedBox(height: 12),

    AppField(
      label: 'Số điện thoại', controller: _phoneCtrl,
      required: true, prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: (v) => (v == null || v.length < 10)
          ? 'Số điện thoại không hợp lệ' : null),
    const SizedBox(height: 12),

    AppField(
      label: 'Email', controller: _emailCtrl,
      required: true, prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (v) => (v == null || !v.contains('@'))
          ? 'Email không hợp lệ' : null),
    const SizedBox(height: 24),

    AppButton(
      label: 'Tiếp tục',
      onPressed: () {
        if (_orgCtrl.text.isEmpty || _nameCtrl.text.isEmpty ||
            _phoneCtrl.text.isEmpty || _emailCtrl.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Vui lòng điền đầy đủ thông tin')));
          return;
        }
        setState(() => _step = 2);
      }),
  ];

  List<Widget> _buildStep2(AuthState auth) => [
    AppField(
      label: 'Mật khẩu', controller: _pwCtrl,
      required: true, obscureText: true,
      validator: (v) => (v == null || v.length < 6)
          ? 'Tối thiểu 6 ký tự' : null),
    const SizedBox(height: 12),

    AppField(
      label: 'Nhập lại mật khẩu', controller: _pw2Ctrl,
      required: true, obscureText: true,
      validator: (v) => v != _pwCtrl.text
          ? 'Mật khẩu không khớp' : null),
    const SizedBox(height: 20),

    // Điều khoản
    GestureDetector(
      onTap: () => setState(() => _agree = !_agree),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 20, height: 20, margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: _agree ? AppColors.primaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: _agree ? AppColors.primaryGreen : AppColors.divider,
              width: 2)),
          child: _agree ? const Icon(Icons.check, size: 13,
              color: Colors.white) : null),
        const SizedBox(width: 10),
        const Expanded(child: Text.rich(TextSpan(children: [
          TextSpan(text: 'Tôi đồng ý với ',
            style: TextStyle(fontSize: 13)),
          TextSpan(text: 'Điều khoản sử dụng',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen)),
          TextSpan(text: ' của ứng dụng.',
            style: TextStyle(fontSize: 13)),
        ]))),
      ]),
    ),
    const SizedBox(height: 20),

    AppButton(
      label: 'Tạo tài khoản',
      isLoading: auth.isLoading,
      onPressed: _agree ? _submit : null),
    const SizedBox(height: 12),

    AppButton(
      label: 'Về đăng nhập',
      variant: AppButtonVariant.text,
      onPressed: () => context.go('/login')),
  ];

  Widget _roleChip(UserRole r, String label, IconData icon, String sub) {
    final on = _role == r;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() { _role = r; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: on ? AppColors.lightGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: on ? AppColors.primaryGreen : AppColors.divider,
            width: on ? 2 : 1)),
        child: Column(children: [
          Icon(icon, size: 22,
              color: on ? AppColors.primaryGreen : AppColors.textHint),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: on ? AppColors.darkGreen : AppColors.textSecondary)),
          Text(sub, style: const TextStyle(
            fontSize: 10.5, color: AppColors.textHint),
            textAlign: TextAlign.center),
        ]),
      ),
    ));
  }
}

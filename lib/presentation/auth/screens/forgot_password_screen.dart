import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_field.dart';
import '../../../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override ConsumerState<ForgotPasswordScreen> createState() => _State();
}

class _State extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override void dispose() { _emailCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppColors.red));
        ref.read(authNotifierProvider.notifier).clearError();
      }
      if (next.success && !_sent) setState(() => _sent = true);
    });

    final auth = ref.watch(authNotifierProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nhập email hoặc số điện thoại đã đăng ký. '
                'Hệ thống sẽ gửi mã xác thực gồm 6 chữ số.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
              const SizedBox(height: 20),
              AppField(
                label: 'Email hoặc số điện thoại',
                controller: _emailCtrl,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.emailAddress,
                initialValue: '0912 345 678',
              ),
              if (_sent) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: const Border(left: BorderSide(color: AppColors.primaryGreen, width: 4)),
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.lightGreen,
                  ),
                  child: Row(children: [
                    const Icon(Icons.check_circle_outline, size: 18, color: AppColors.primaryGreen),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      'Đã gửi mã xác thực tới ${_emailCtrl.text}. Mã có hiệu lực trong 5 phút.',
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4))),
                  ]),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: 'Gửi mã xác thực',
                isLoading: auth.isLoading,
                onPressed: () async {
                  if (_emailCtrl.text.trim().isEmpty) return;
                  await ref.read(authNotifierProvider.notifier)
                      .sendPasswordReset(_emailCtrl.text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

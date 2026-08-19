import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../presentation/auth/screens/forgot_password_screen.dart';
import '../presentation/auth/screens/login_screen.dart';
import '../presentation/auth/screens/register_screen.dart';
import '../presentation/auth/screens/splash_screen.dart';
import '../presentation/buyer/screens/buyer_lot_detail_screen.dart';
import '../presentation/buyer/screens/buyer_place_order_screen.dart';
import '../presentation/buyer/screens/buyer_shell.dart';
import '../presentation/buyer/screens/buyer_tracking_screen.dart';
import '../presentation/htx/screens/htx_create_lot_screen.dart';
import '../presentation/htx/screens/htx_order_detail_screen.dart';
import '../presentation/htx/screens/htx_shell.dart';

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthNotifier(),

    // Trang lỗi 404 — thân thiện hơn
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Không tìm thấy trang'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64,
                color: AppColors.textHint),
            const SizedBox(height: 16),
            const Text('Trang không tồn tại',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(state.matchedLocation,
              style: const TextStyle(fontSize: 12,
                  color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Về trang chủ')),
          ],
        ),
      ),
    ),

    redirect: (context, state) {
      final user       = FirebaseAuth.instance.currentUser;
      final loc        = state.matchedLocation;
      final isAuthPage = loc == '/login' || loc == '/register' ||
                         loc == '/forgot' || loc == '/splash';

      if (user == null) return isAuthPage ? null : '/login';
      return null;
    },

    routes: [
      GoRoute(path: '/splash',   builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login',    builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot',   builder: (_, __) => const ForgotPasswordScreen()),

      // ── HTX ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/htx',
        builder: (_, __) => const HtxShell(),
        routes: [
          // Tạo lô hàng mới
          GoRoute(
            path: 'create-lot',
            builder: (_, __) => const HtxCreateLotScreen(),
          ),
          // Chi tiết lô hàng (HTX xem lô của mình)
          // Dùng BuyerLotDetailScreen vì UI giống nhau
          GoRoute(
            path: 'lot/:id',
            builder: (_, s) =>
                BuyerLotDetailScreen(lotId: s.pathParameters['id']!),
          ),
          // Chi tiết đơn hàng
          GoRoute(
            path: 'order/:id',
            builder: (_, s) =>
                HtxOrderDetailScreen(orderId: s.pathParameters['id']!),
          ),
          // Danh sách đơn hàng (từ profile/dashboard navigate)
          GoRoute(
            path: 'orders',
            builder: (_, __) => const HtxShell(),
          ),
          // Tồn kho (từ profile navigate)
          GoRoute(
            path: 'inventory',
            builder: (_, __) => const HtxShell(),
          ),
        ],
      ),

      // ── Buyer ────────────────────────────────────────────────────────────
      GoRoute(
        path: '/buyer',
        builder: (_, __) => const BuyerShell(),
        routes: [
          // Tìm kiếm
          GoRoute(
            path: 'search',
            builder: (_, __) => const BuyerShell(),
          ),
          // Chi tiết lô hàng
          GoRoute(
            path: 'lot/:id',
            builder: (_, s) =>
                BuyerLotDetailScreen(lotId: s.pathParameters['id']!),
          ),
          // Đặt hàng
          GoRoute(
            path: 'place-order/:id',
            builder: (_, s) =>
                BuyerPlaceOrderScreen(lotId: s.pathParameters['id']!),
          ),
          // Chi tiết đơn hàng (buyer theo dõi)
          GoRoute(
            path: 'order/:id',
            builder: (_, s) =>
                BuyerLotDetailScreen(lotId: s.pathParameters['id']!),
          ),
          // Theo dõi vận chuyển
          GoRoute(
            path: 'tracking/:id',
            builder: (_, s) =>
                BuyerTrackingScreen(orderId: s.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});

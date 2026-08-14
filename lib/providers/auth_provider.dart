import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/enums/app_enums.dart';
import '../data/models/user_model.dart';
import 'firebase_providers.dart';

// ── Current UserModel ─────────────────────────────────────────────────────
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  final doc = await ref.read(firestoreProvider)
      .collection(AppConstants.usersCol).doc(user.uid).get();
  if (!doc.exists) return null;
  return UserModel.fromFirestore(doc);
});

// ── Auth ViewModel ────────────────────────────────────────────────────────
class AuthState {
  final bool isLoading;
  final String? error;
  final bool success;

  const AuthState({this.isLoading = false, this.error, this.success = false});
  AuthState copyWith({bool? isLoading, String? error, bool? success, bool clearError = false}) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        error:     clearError ? null : (error ?? this.error),
        success:   success ?? this.success,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthNotifier(this._auth, this._db) : super(const AuthState());

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      state = state.copyWith(isLoading: false, success: true);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _mapError(e.code));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Đã xảy ra lỗi. Vui lòng thử lại.');
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required String phone,
    required String orgName,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      final uid = cred.user!.uid;
      final user = UserModel(
        uid: uid, email: email.trim(),
        displayName: displayName.trim(), phone: phone.trim(),
        orgName: orgName.trim(), role: role,
        isVerified: true, // tất cả đều kích hoạt ngay, không cần duyệt
        createdAt: DateTime.now(),
      );
      await _db.collection(AppConstants.usersCol).doc(uid).set(user.toFirestore());
      state = state.copyWith(isLoading: false, success: true);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _mapError(e.code));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Đã xảy ra lỗi. Vui lòng thử lại.');
    }
  }

  Future<void> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      state = state.copyWith(isLoading: false, success: true);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _mapError(e.code));
    }
  }

  Future<void> logout() async => _auth.signOut();
  void clearError() => state = state.copyWith(clearError: true, success: false);

  String _mapError(String code) {
    const m = {
      'user-not-found':     'Email chưa được đăng ký.',
      'wrong-password':     'Mật khẩu không đúng.',
      'email-already-in-use':'Email này đã có tài khoản.',
      'weak-password':      'Mật khẩu quá yếu (tối thiểu 6 ký tự).',
      'invalid-email':      'Email không hợp lệ.',
      'user-disabled':      'Tài khoản đã bị khóa.',
      'too-many-requests':  'Quá nhiều lần thử. Vui lòng thử lại sau.',
      'network-request-failed':'Lỗi mạng. Kiểm tra kết nối internet.',
    };
    return m[code] ?? 'Xác thực thất bại: $code';
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(firebaseAuthProvider), ref.read(firestoreProvider));
});

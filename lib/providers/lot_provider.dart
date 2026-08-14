import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../data/models/lot_model.dart';
import 'firebase_providers.dart';

// ── Featured lots (Buyer Home) ────────────────────────────────────────────
// Không dùng orderBy để tránh cần composite index
final featuredLotsProvider = FutureProvider<List<LotModel>>((ref) async {
  final snap = await ref.read(firestoreProvider)
      .collection(AppConstants.lotsCol)
      .where('status', isEqualTo: 'active')
      .limit(20)
      .get();
  final list = snap.docs.map(LotModel.fromFirestore).toList();
  // Sort client-side
  list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return list.take(10).toList();
});

// ── All lots (buyer search) ───────────────────────────────────────────────
final allLotsProvider = FutureProvider.family<List<LotModel>, String?>((ref, province) async {
  var q = ref.read(firestoreProvider)
      .collection(AppConstants.lotsCol)
      .where('status', isEqualTo: 'active');

  final snap = await q.limit(AppConstants.pageSize).get();
  final list = snap.docs.map(LotModel.fromFirestore).toList();

  // Filter province client-side
  final filtered = province != null
      ? list.where((l) => l.province == province).toList()
      : list;

  // Sort client-side
  filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return filtered;
});

// ── Lots by seller (HTX) ──────────────────────────────────────────────────
final sellerLotsProvider = FutureProvider.family<List<LotModel>, String>((ref, sellerId) async {
  if (sellerId.isEmpty) return [];
  final snap = await ref.read(firestoreProvider)
      .collection(AppConstants.lotsCol)
      .where('sellerId', isEqualTo: sellerId)
      .get();
  final list = snap.docs.map(LotModel.fromFirestore).toList();
  list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return list;
});

// ── Single lot realtime ───────────────────────────────────────────────────
final lotDetailProvider = StreamProvider.family<LotModel?, String>((ref, id) {
  return ref.read(firestoreProvider)
      .collection(AppConstants.lotsCol)
      .doc(id)
      .snapshots()
      .map((s) => s.exists ? LotModel.fromFirestore(s) : null);
});

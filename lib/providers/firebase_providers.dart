import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/remote/cloudinary_service.dart';

// ── Firebase instances ────────────────────────────────────────────────────
final firebaseAuthProvider = Provider<FirebaseAuth>((_) => FirebaseAuth.instance);
final firestoreProvider    = Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);
// firebase_storage đã được thay bằng Cloudinary (miễn phí)
final cloudinaryProvider   = Provider<CloudinaryService>((_) => CloudinaryService());

// ── Auth state stream ─────────────────────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

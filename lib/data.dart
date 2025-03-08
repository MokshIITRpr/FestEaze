import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Singleton cache for the user data
class UserData {
  static final UserData _instance = UserData._internal();
  factory UserData() => _instance;
  UserData._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache the future and the associated UID
  Future<DocumentSnapshot>? _user;
  String? _cachedUid;

  Future<DocumentSnapshot> _fetchUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception("No user is currently logged in.");
    }
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc;
    } catch (e) {
      throw Exception("Failed to load user: $e");
    }
  }

  Future<DocumentSnapshot> getUser() async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) {
      throw Exception("No user is currently logged in.");
    }

    if (_user != null && _cachedUid == currentUid) {
      return await _user!;
    }
    _cachedUid = currentUid;
    _user = _fetchUser();
    return await _user!;
  }

  void clearCache() {
    print("Clearing cached user data...");
    _user = null;
    _cachedUid = null;
  }
}

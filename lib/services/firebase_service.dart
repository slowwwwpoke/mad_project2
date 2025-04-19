
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/stock.dart';

class FirebaseService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static bool isUserLoggedIn() => _auth.currentUser != null;

  static Future<void> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static Future<void> saveToWatchlist(Stock stock) async {
    final uid = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(uid).collection('watchlist').doc(stock.symbol).set(stock.toMap());
  }

  static Stream<List<Stock>> getWatchlist() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('watchlist')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Stock.fromJson(doc.data())).toList());
  }

  static Future<void> deleteFromWatchlist(String symbol) async {
    final uid = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(uid).collection('watchlist').doc(symbol).delete();
  }
}

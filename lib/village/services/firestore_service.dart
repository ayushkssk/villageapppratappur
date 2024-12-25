import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_update.dart';
import '../models/event.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // News Updates
  Stream<QuerySnapshot> getNewsUpdates() {
    return _firestore
        .collection('news')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> addNewsUpdate(NewsUpdate newsUpdate) async {
    await _firestore.collection('news').doc(newsUpdate.id).set(newsUpdate.toMap());
  }

  Future<void> updateNewsUpdate(String id, Map<String, dynamic> data) async {
    await _firestore.collection('news').doc(id).update(data);
  }

  Future<void> deleteNewsUpdate(String id) async {
    await _firestore.collection('news').doc(id).delete();
  }

  // Events
  Stream<QuerySnapshot> getEvents() {
    return _firestore
        .collection('events')
        .orderBy('date')
        .snapshots();
  }

  Future<void> addEvent(Event event) async {
    await _firestore.collection('events').doc(event.id).set(event.toMap());
  }

  Future<void> deleteEvent(String id) async {
    await _firestore.collection('events').doc(id).delete();
  }

  // Weather
  Stream<Map<String, dynamic>> getWeatherUpdateStream() {
    return _firestore
        .collection('weather')
        .doc('current')
        .snapshots()
        .map((doc) => doc.data() ?? {});
  }

  Future<Map<String, dynamic>> getWeatherUpdate() async {
    final doc = await _firestore.collection('weather').doc('current').get();
    return doc.data() ?? {};
  }

  Future<void> updateWeather(Map<String, dynamic> weatherData) async {
    await _firestore.collection('weather').doc('current').set(weatherData);
  }

  // Emergency Alerts
  Stream<QuerySnapshot> getEmergencyAlerts() {
    return _firestore
        .collection('emergency_alerts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> addEmergencyAlert(Map<String, dynamic> alert) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    alert['id'] = id;
    await _firestore.collection('emergency_alerts').doc(id).set(alert);
  }

  Future<void> deleteEmergencyAlert(String id) async {
    await _firestore.collection('emergency_alerts').doc(id).delete();
  }

  // Reels
  Stream<QuerySnapshot> getReels() {
    return _firestore
        .collection('reels')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> addReel(Map<String, dynamic> reel) async {
    await _firestore.collection('reels').add(reel);
  }

  Future<void> deleteReel(String id) async {
    await _firestore.collection('reels').doc(id).delete();
  }
}

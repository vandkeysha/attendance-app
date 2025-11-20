import 'package:attendance_app/main.dart';
import 'package:attendance_app/models/attendance_records.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get attendance records for user (real-time stream)
  Stream<List<AttendanceRecords>> getAttendanceRecord(String userId) {
    return ;
  }

}
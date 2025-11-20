import 'package:attendance_app/models/attendance_records.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get attendance records for user (real-time stream)
  Stream<List<AttendanceRecords>> getAttendanceRecord(String userId) {
    return _firestore  // firestore untuk menyimpan userid, realtime dan lainnya
        .collection('attendance')
        .where('user_id', isEqualTo: userId)
        .orderBy('check_in_time', descending: true)
        .snapshots()
        .map((snapshot){
          return snapshot.docs
                .map((doc) => AttendanceRecords.fromJson({...doc.data(), 'id': doc.id}))
                .toList();
      });
  }

  // get today attendance record (real-time stream)
  Stream<AttendanceRecords?> getTodayRecordStream(String userId){
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    return _firestore
        .collection('attendance')
        .where('user_id', isEqualTo: userId)
        .orderBy('check_in_time', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot){
          //filter today 's record on client side
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final checkInTime = DateTime.parse(data['check_in_time'] as String);

          if (checkInTime.isAfter(startOfDay) && checkInTime.isBefore(endOfDay)) {
            return AttendanceRecords.fromJson({...data, 'id':doc.id} );
          }
        }
        return null;
      });
  }

  // get today's attendance record()
  Future<AttendanceRecords?> getTodayRecord(String userId) async{
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    final querySnapshot = await _firestore
        .collection('attendance')
        .where('user_id', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    if(querySnapshot.docs.isEmpty) return null;

    return AttendanceRecords.fromJson(
      {...querySnapshot.docs.first.data(), 'id': querySnapshot.docs.first.id}
    );
  }

  // create new attendance record
  Future<String> createAttendanceRecords(AttendanceRecords record) async{
    final docRef = await _firestore.collection('attendance').add(record.toJson());

    return docRef.id;
  }

  // update existing attendance record

  Future<void> updateAttendanceRecord(AttendanceRecords record) async {
    await _firestore
      .collection('attendance')
      .doc(record.id)
      .update(record.toJson());
  }

  // create or update Attendance record
  Future<void> saveAttendanceRecords(AttendanceRecords record) async{
    if (record.id == '1' || record.id.isEmpty) {
      //  new record for creating auto generated ID
      await createAttendanceRecords(record);
    } else {
      // update existing record
       await updateAttendanceRecord(record);
    }
  }
  }
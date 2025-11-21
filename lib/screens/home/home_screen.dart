import 'package:attendance_app/models/attendance_records.dart';
import 'package:attendance_app/services/auth_services.dart';
import 'package:attendance_app/services/firestore_service.dart';
import 'package:attendance_app/services/storage_services.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthServices _authServices = AuthServices();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageServices _storageServices = StorageServices();
  AttendanceRecords? _todayRecord;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _listenToTodayRecord();
  }

  // mendengarkan semua hal yg terjadi di homescreen ->attendance record
  void _listenToTodayRecord() {
    final user = _authServices.currentUser;
    if (user != null) {
      _firestoreService.getTodayRecordStream(user.uid).listen((record) {
        // masih aktif
        if (mounted) setState(() => _todayRecord = record);
      });
    }
  }

  // utk check in
  Future<void> _CheckIn({String? photoPath}) async {
    final user = _authServices.currentUser;
    // kalo user tidak ada di database
    if (user == null) return null;

    setState(() => _isLoading = true);

    // percobaan utk take photo ketika check in
    try {
      String? photoKey;
      if (photoPath != null) {
        photoKey = await _storageServices.uploadAttendancePhoto(
          photoPath,
          'CheckIn',
        );
      }

      final now = DateTime.now();
      final record = AttendanceRecords(
        id: '',
        userId: user.uid,
        checkInTime: now,
        date: DateTime(now.year, now.month, now.day),
        checkInPhotoPath: photoKey,
      );

      await _firestoreService.createAttendanceRecords(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              photoPath != null
                  ? 'Check in successfully with photo!'
                  : 'Check in successfully',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // kalau tidak berhasil check in
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checkhing in: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // check out
  Future<void> _checkOut({String? photoPath}) async {
    if (_todayRecord == null) return;

    setState(() => _isLoading = true);

    try {
      String? photoKey;
      if (photoPath != null) {
        photoKey = await _storageServices.uploadAttendancePhoto(
          photoPath,
          'checkout',
        );
      }

      final updateRecord = AttendanceRecords(
        id: _todayRecord!.id,
        userId: _todayRecord!.userId,
        checkInTime: _todayRecord!.checkInTime,
        checkOutTime: DateTime.now(),
        date: _todayRecord!.date,
        checkInPhotoPath: _todayRecord!.checkInPhotoPath,
        CheckOutPhotoPath: photoKey,
      );

      await _firestoreService.updateAttendanceRecord(updateRecord);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              photoPath != null
                  ? 'Checked Out successfully with photo'
                  : 'Check Out succesfully',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error Checking Out : ${e.toString()}'
            ),
            backgroundColor: Colors.red,
           )
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('attendance Tracker'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () { 
              //TODO: Go to history screen
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async => await _authServices.signOut(),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[700]!,
              Colors.grey[50]!
            ],  
            stops: [0,0,0.3] //dia bakal berhenti di titik 0.3 adalah posisi di mana layar nya posisi di tengah
          )
        ),
      ),
    );
  }
}
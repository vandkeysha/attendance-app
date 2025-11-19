import 'package:attendance_app/wrapper/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCLrbGSZmo7Wv1BFhCES32wj2Y6uCv-hQ0",
      appId: "1:68276566831:android:71b48647c46fa51e59bfda",
      messagingSenderId: "68276566831",
      projectId: "attendance-app-4fe20",

    )
  );
  runApp(attendance_app());
  
}

class attendance_app extends StatelessWidget {
  const attendance_app ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'attendance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
        )
      ),
      home: AuthWrapper(),
    );
  }
}
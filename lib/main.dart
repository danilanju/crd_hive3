import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_crud/homepage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mendapatkan direktori aplikasi
  final appDocumentDir = await path_provider.getExternalStorageDirectory();
  final hiveStorageDir = Directory('${appDocumentDir!.path}/DB/hive');
  hiveStorageDir.createSync(recursive: true);

  // Inisialisasi Hive dengan direktori DCIM
  Hive.init(hiveStorageDir.path);

  await Hive.initFlutter();
  await Hive.openBox('daftar_anggota');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'testhive',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

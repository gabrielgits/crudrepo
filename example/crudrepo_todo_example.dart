import 'package:crudrepo/crudrepo.dart';

import 'ui/home_screen.dart';
import 'package:flutter/material.dart';

void main() async {

 WidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for sqflite_ffi
  FedsLocalSqfliteFfi.initDesktopDb();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

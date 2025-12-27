import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import screen
import 'package:preskom/login_screen.dart';
import 'package:preskom/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    debugPrint("Error initializing date formatting: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PresKom SMK Telkom Lampung',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD32F2F),
          primary: const Color(0xFFD32F2F),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // Set LoginScreen sebagai halaman awal
      home: const LoginScreen(),

      // Gunakan routes hanya untuk halaman yang tidak butuh parameter (seperti Register)
      routes: {
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'ui/login_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initNotification(); // Inicializa o serviço de notificações antes de rodar o app

  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Post Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter', // Se você quiser um ar bem moderno, use essa fonte
      ),
      home: const LoginScreen(),
    );
  }
}

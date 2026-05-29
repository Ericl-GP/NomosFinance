import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart'; // <-- Novo import
import 'ui/login_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await NotificationService().initNotification();

  // ==========================================
  // CONFIGURAÇÃO DE LAYOUT PARA DESKTOP
  // ==========================================
  // Verifica se NÃO é Web e se está rodando no Windows, Linux ou macOS
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(400, 800), // Tamanho fixo simulando a tela de um celular
      center: true, // Centraliza a janela no monitor
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setResizable(false); // TRAVA O REDIMENSIONAMENTO (Mouse nas bordas)
      await windowManager.setMaximizable(false); // DESATIVA O BOTÃO DE MAXIMIZAR
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nomos Finance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      // Opcional: Garante que mesmo na Web o app fique centralizado como um celular
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500, // Largura máxima permitida na Web
            ),
            child: child,
          ),
        );
      },
      home: const LoginScreen(),
    );
  }
}
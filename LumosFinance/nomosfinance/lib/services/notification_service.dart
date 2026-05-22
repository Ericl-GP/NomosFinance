import 'dart:io';
import 'package:flutter/foundation.dart'; // Necessário para saber se é Web
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    // 🛡️ ESCUDO: Se estiver testando na Web ou no Windows, ignora a inicialização nativa
    if (kIsWeb || Platform.isWindows) {
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings, 
    );
  }

  // Função para disparar a notificação
  Future<void> mostrarNotificacaoImediata({required int id, required String title, required String body}) async {
    // 🛡️ ESCUDO: Na Web/Windows, apenas avisa no terminal que a notificação foi acionada
    if (kIsWeb || Platform.isWindows) {
      print('🔔 Notificação (Simulada no Windows): $title - $body');
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'nomos_finance_channel_id', 
      'Anotações e Lembretes',    
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', 
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: id, 
      title: title, 
      body: body, 
      notificationDetails: details, 
    );
  }
}
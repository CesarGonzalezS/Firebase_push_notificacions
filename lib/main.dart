import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Función para manejar mensajes en segundo plano de Firebase Messaging.
/// Inicializa Firebase y muestra el título del mensaje recibido en la consola.
Future<void> _firebaseMessagingHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print(
      "Estoy capturando el mensaje en segundo plano: ${message.notification?.title}");
}

/// Configuración específica para Android.
/// Utiliza el icono de la aplicación como icono de notificación en Android.
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

/// Configuración específica para iOS (usando la configuración de Darwin).
/// Esta configuración permite personalizar las notificaciones en dispositivos Apple.
final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings();

/// Configuración general de inicialización para notificaciones locales.
/// Combina las configuraciones específicas de Android e iOS.
final InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
  iOS: initializationSettingsDarwin,
);

/// Instancia del plugin de notificaciones locales.
/// Esta instancia permite mostrar notificaciones dentro de la aplicación.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configura un controlador para manejar mensajes de Firebase en segundo plano.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingHandler);

  // Inicializa el plugin de notificaciones locales.
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Ejecuta la aplicación principal.
  runApp(const MyApp());
}

/// Clase principal de la aplicación que representa el widget raíz.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// Estado de la clase `MyApp` donde se configura el permiso para notificaciones.
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Instancia de Firebase Messaging para gestionar notificaciones.
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Solicita permisos para recibir notificaciones en el dispositivo.
    messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Configura un controlador para manejar mensajes recibidos mientras la app está en primer plano.
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      print("Estoy obteniendo una notificación en primer plano");
      print("Datos de la notificación: ${remoteMessage.data}");

      // Muestra una notificación local cuando se recibe un mensaje en primer plano.
      flutterLocalNotificationsPlugin.show(
        remoteMessage.hashCode,
        remoteMessage.notification?.title,
        remoteMessage.notification?.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'id_de_prueba',
            'Canal_de_prueba',
            channelDescription: 'Demostración',
            importance: Importance.max,
            priority: Priority.max,
          ),
        ),
      );

      if (remoteMessage.notification != null) {
        print("Mensaje: ${remoteMessage.notification}");
      }
    });

    // Obtiene y muestra el token de dispositivo.
    FirebaseMessaging.instance.getToken().then((token) {
      print("Token del dispositivo: $token");
    });
  }

  //dlG3m4o2Qja5V9GeNQFukd:APA91bGQ3xrAWmu9ny3vDHnhkRwnLxcMeA-wpuG6j3p7a5XjNVTOH_Qg6I252Vjv4Zxszw9ApCVgAu4wAo99Y81uiv5hktk4oFhGQGOo-NTIitcIfCRQMJo

  /// Construye el widget principal de la aplicación.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Notificaciones push"),
        ),
        body: const Center(
          child: Text("ESPERA DE LA NOTIFICACION"),
        ),
      ),
    );
  }
}

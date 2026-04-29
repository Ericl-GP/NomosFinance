class ApiConstants {
  // Se for Android Emulator, use 10.0.2.2
  // Se for iOS ou dispositivo físico, use o IP real da sua máquina
  static String baseUrl = 'http://127.0.0.1:8000/api';
  static String storageBaseUrl = 'http://127.0.0.1:8000'; // URL base para storage (sem /api)
  static String loginEndpoint = '/login';
  static String logoutEndpoint = '/logout';
}

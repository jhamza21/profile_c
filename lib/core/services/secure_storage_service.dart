import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static saveToken(String token) async {
    final storage = new FlutterSecureStorage();
    await storage.write(key: 'jwt', value: token);
  }

  static Future<String> readToken() async {
    final storage = new FlutterSecureStorage();
    return await storage.read(key: 'jwt');
  }

  static deleteToken() async {
    final storage = new FlutterSecureStorage();
    await storage.delete(key: 'jwt');
  }

  static saveClientInfo(String clientInfo) async {
    final storage = new FlutterSecureStorage();
    await storage.write(key:'deviceId', value: clientInfo);
  }

   static Future<String> readClientInfo() async {
    final storage = new FlutterSecureStorage();
    return await storage.read(key: 'deviceId');
  }


  static saveClientEmail(String email) async {
    final storage = new FlutterSecureStorage();
    await storage.write(key:'email', value: email);
  }


    static Future<String> readClientEmail() async {
    final storage = new FlutterSecureStorage();
    return await storage.read(key: 'email');
  }





}

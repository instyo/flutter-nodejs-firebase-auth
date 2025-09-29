import 'package:auth_test/core/auth_model.dart';
import 'package:get_storage/get_storage.dart';

class AuthStorage {
  AuthStorage._();

  static final AuthStorage _instance = AuthStorage._();

  factory AuthStorage() {
    return _instance;
  }

  static final box = GetStorage();

  static Future<void> saveAuthData(Map<String, dynamic> authData) async {
    await box.write('auth_data', authData);
  }

  // get saved auth data, or null if none
  static AuthModel? getAuthData() {
    final data = box.read<Map<String, dynamic>?>('auth_data');
    return data != null ? AuthModel.fromJson(data) : null;
  }

  static bool? getIsVerified() {
    return getAuthData()?.emailVerified;
  }
}

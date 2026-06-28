import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  // 🔑 Keys
  static const String _userNameKey = "user_name";
  static const String _userEmailKey = "user_email";
  static const String _userPasswordKey = "user_password";
  static const String _userMobileNumber = "user_mobile_number";

  // 🔑 Model Selection Keys
  static const String _selectedModelIdKey = "selected_model_id";
  static const String _selectedModelNameKey = "selected_model_name";
  static const String _selectedModelDescriptionKey = "selected_model_description";
  static const String _selectedModelApiNameKey = "selected_model_api_name";
  static const String _selectedModelUseCaseKey = "selected_model_use_case";
  static const String _selectedModelCategoryKey = "selected_model_category";

  // SharedPreferences instance
  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // ========= User Data Setters =========
  static Future<void> setUserName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_userNameKey, name);
  }

  static Future<void> setUserEmail(String email) async {
    final prefs = await _prefs;
    await prefs.setString(_userEmailKey, email);
  }

  static Future<void> setUserPassword(String password) async {
    final prefs = await _prefs;
    await prefs.setString(_userPasswordKey, password);
  }

  static Future<void> setUserMobile(String mobile) async {
    final prefs = await _prefs;
    await prefs.setString(_userMobileNumber, mobile);
  }

  // ========= Model Data Setters =========
  static Future<void> setSelectedModel({
    required String id,
    required String name,
    required String description,
    required String apiModelName,
    required String useCase,
    required String category,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_selectedModelIdKey, id);
    await prefs.setString(_selectedModelNameKey, name);
    await prefs.setString(_selectedModelDescriptionKey, description);
    await prefs.setString(_selectedModelApiNameKey, apiModelName);
    await prefs.setString(_selectedModelUseCaseKey, useCase);
    await prefs.setString(_selectedModelCategoryKey, category);
  }

  static Future<void> clearSelectedModel() async {
    final prefs = await _prefs;
    await prefs.remove(_selectedModelIdKey);
    await prefs.remove(_selectedModelNameKey);
    await prefs.remove(_selectedModelDescriptionKey);
    await prefs.remove(_selectedModelApiNameKey);
    await prefs.remove(_selectedModelUseCaseKey);
    await prefs.remove(_selectedModelCategoryKey);
  }

  // ========= User Data Getters =========
  static Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(_userNameKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await _prefs;
    return prefs.getString(_userEmailKey);
  }

  static Future<String?> getUserPassword() async {
    final prefs = await _prefs;
    return prefs.getString(_userPasswordKey);
  }

  static Future<String?> getUserMobile() async {
    final prefs = await _prefs;
    return prefs.getString(_userMobileNumber);
  }

  // ========= Model Data Getters =========
  static Future<String?> getSelectedModelId() async {
    final prefs = await _prefs;
    return prefs.getString(_selectedModelIdKey);
  }

  static Future<String?> getSelectedModelName() async {
    final prefs = await _prefs;
    return prefs.getString(_selectedModelNameKey);
  }

  static Future<String?> getSelectedModelDescription() async {
    final prefs = await _prefs;
    return prefs.getString(_selectedModelDescriptionKey);
  }

  static Future<String?> getSelectedModelApiName() async {
    final prefs = await _prefs;
    return prefs.getString(_selectedModelApiNameKey);
  }

  static Future<String?> getSelectedModelUseCase() async {
    final prefs = await _prefs;
    return prefs.getString(_selectedModelUseCaseKey);
  }

  static Future<String?> getSelectedModelCategory() async {
    final prefs = await _prefs;
    return prefs.getString(_selectedModelCategoryKey);
  }

  // Check if any model is selected
  static Future<bool> hasSelectedModel() async {
    final prefs = await _prefs;
    return prefs.getString(_selectedModelIdKey) != null;
  }

  // Get all selected model data as a map
  static Future<Map<String, String?>> getSelectedModelData() async {
    final prefs = await _prefs;
    return {
      'id': prefs.getString(_selectedModelIdKey),
      'name': prefs.getString(_selectedModelNameKey),
      'description': prefs.getString(_selectedModelDescriptionKey),
      'apiModelName': prefs.getString(_selectedModelApiNameKey),
      'useCase': prefs.getString(_selectedModelUseCaseKey),
      'category': prefs.getString(_selectedModelCategoryKey),
    };
  }

  // ========= Clear All Data =========
  static Future<void> clearUserData() async {
    final prefs = await _prefs;
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userPasswordKey);
  }

  static Future<void> clearAllData() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
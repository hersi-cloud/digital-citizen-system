import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, String> _currentUser = {};

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, String> get currentUser => _currentUser;

  Future<bool> updateUserInfo({String? fullName, String? email, String? address, String? birthPlace, String? password, String? profileImage}) async {
      _isLoading = true;
      notifyListeners();
      try {
          final data = {
              if (fullName != null) 'fullName': fullName,
              if (email != null) 'email': email,
              if (address != null) 'address': address,
              if (birthPlace != null) 'birthPlace': birthPlace,
              if (password != null && password.isNotEmpty) 'password': password,
              if (profileImage != null) 'profileImage': profileImage,
          };
          
          final response = await _apiService.put('/auth/profile', data);
          
          // Xogta local-ka ah cusboonaysii
          _currentUser = {
              'email': response['email'],
              'name': response['fullName'] ?? _currentUser['name'] ?? '',
              'role': response['role'],
              if (response['profileImage'] != null) 'profileImage': response['profileImage'],
          };
          
          final prefs = await SharedPreferences.getInstance();
          if (response['token'] != null) {
              await prefs.setString('token', response['token']); // Token-ku wuu isbedeli karaa hadii password-ka la bedelo
          }
          await prefs.setString('user_email', response['email']);
          if (response['profileImage'] != null) {
             await prefs.setString('user_image', response['profileImage']);
          }

          _isLoading = false;
          notifyListeners();
          return true;
      } catch (e) {
          _errorMessage = e.toString();
          _isLoading = false;
          notifyListeners();
          return false;
      }
  }

  // Admin: Cusboonaysii xogta user kale
  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
       _isLoading = true;
       notifyListeners();
       try {
           final response = await _apiService.put('/auth/users/$userId', data);
           
           // Liiska local-ka ah cusboonaysii hadduu jiro
           final index = _users.indexWhere((u) => u['_id'] == userId);
           if (index != -1) {
               _users[index] = response;
           }
           
           _isLoading = false;
           notifyListeners();
           return true;
       } catch (e) {
           _errorMessage = e.toString();
           _isLoading = false;
           notifyListeners();
           return false;
       }
  }

  Future<bool> deleteUser(String userId) async {
      _isLoading = true;
      notifyListeners();
      try {
          await _apiService.delete('/auth/users/$userId');
          
          _users.removeWhere((u) => u['_id'] == userId);
          
          _isLoading = false;
          notifyListeners();
          return true;
      } catch (e) {
          _errorMessage = e.toString();
          _isLoading = false;
          notifyListeners();
          return false;
      }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final token = response['token'];
      final role = response['role'] ?? 'User';
      final image = response['profileImage'];
      final name = response['fullName'];
      
      // Xogta user-ka ee local-ka ah cusboonaysii
      _currentUser = {
        'email': email, 
        'name': name ?? email.split('@')[0],
        'role': role,
        if (image != null) 'profileImage': image
      };
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('user_email', email);
      await prefs.setString('user_role', role);
      if (image != null) {
          await prefs.setString('user_image', image);
      }
      
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String fullName, String birthPlace, String address) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/register', {
        'email': email,
        'password': password,
        'fullName': fullName,
        'birthPlace': birthPlace,
        'address': address,
      });

      // Don't auto-login, just return true
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _isAuthenticated = false;
    _currentUser = {};
    notifyListeners();
  }

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> get users => _users;

  Future<void> fetchAllUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/auth/users');
      _users = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _isAuthenticated = true;
      final email = prefs.getString('user_email') ?? 'User';
      final role = prefs.getString('user_role') ?? 'User';
      final image = prefs.getString('user_image');
      
      _currentUser = {
          'email': email, 
          'name': email.split('@')[0], // Fallback name if local storage not fully synced
          'role': role,
          if (image != null) 'profileImage': image
      };
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
  }
}

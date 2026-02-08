import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegistrationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<dynamic> _requests = [];
  List<dynamic> _registrations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get requests => _requests;
  List<dynamic> get registrations => _registrations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRegistrations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // In a real app, we would have separate calls, but here we can call both.
      // We are assuming that /registrations returns birth registrations.
      final response = await _apiService.get('/registrations');
      _registrations = response;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRequests() async {
      _isLoading = true;
      notifyListeners();
      try {
          print('Fetching user requests...');
          final response = await _apiService.get('/requests');
          print('Fetched ${response.length} requests');
          _requests = response;
      } catch (e) {
          print('Error fetching requests: $e');
           // Qari qaladka hadda ama xalli
      } finally {
          _isLoading = false;
          notifyListeners();
      }
  }

  Future<bool> createRegistration(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.postAuth('/registrations', data);
      await fetchRegistrations(); 
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

  Future<bool> createRequest(String type, Map<String, dynamic> details) async {
       _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      try {
        await _apiService.postAuth('/requests', {
            'type': type,
            'details': details
        });
        await fetchRequests();
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

  // Admin Methods (Qaababka Admin-ka)
  Future<void> fetchAllRequests() async {
      _isLoading = true;
      notifyListeners();
      try {
          final response = await _apiService.get('/requests/all');
          _requests = response; // Admin-ku wuxuu arkaa dhammaan codsiyada
      } catch (e) {
          print('Error fetching all requests: $e');
      } finally {
          _isLoading = false;
          notifyListeners();
      }
  }

  Future<bool> updateRequestStatus(String id, String newStatus, {String? adminNote}) async {
      _isLoading = true;
      notifyListeners();
      try {
          final data = {'status': newStatus};
          if (adminNote != null) {
            data['adminNote'] = adminNote;
          }
          
          await _apiService.put('/requests/$id', data);
          await fetchAllRequests(); // Refresh list (Cusboonaysii liiska)
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
}

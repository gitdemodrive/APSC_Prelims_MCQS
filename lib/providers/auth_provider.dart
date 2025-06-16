import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../models/user.dart' as app_models;

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  bool _isLoading = false;
  String? _error;
  app_models.User? _currentUser;
  
  AuthProvider() {
    // Listen to auth state changes
    _supabaseService.authStateChanges.listen((event) {
      _loadUserProfile();
      notifyListeners();
    });
    
    // Load user profile on initialization
    _loadUserProfile();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _supabaseService.isAuthenticated();
  String? get currentUserId => _supabaseService.getCurrentUserId();
  Stream<dynamic> get authStateChanges => _supabaseService.authStateChanges;
  app_models.User? get currentUser => _currentUser;

  // Sign up with email and password
  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _supabaseService.signUp(email, password);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sign up failed: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _supabaseService.signIn(email, password);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sign in failed: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _error = null;
    
    try {
      await _supabaseService.signOut();
      notifyListeners();
    } catch (e) {
      _error = 'Sign out failed: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear any error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Load user profile
  Future<void> _loadUserProfile() async {
    if (!isAuthenticated) {
      _currentUser = null;
      return;
    }
    
    try {
      _currentUser = await _supabaseService.getUserProfile();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user profile: ${e.toString()}';
    }
  }
  
  // Public method to refresh user profile
  Future<void> refreshUserProfile() async {
    return _loadUserProfile();
  }
  
  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? qualification,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _supabaseService.updateUserProfile(
        name: name,
        phoneNumber: phoneNumber,
        qualification: qualification,
      );
      
      // Reload user profile after update
      await _loadUserProfile();
      return true;
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Get average quiz score
  Future<double> getAverageQuizScore() async {
    try {
      return await _supabaseService.getAverageQuizScore();
    } catch (e) {
      _error = 'Failed to get average score: ${e.toString()}';
      return 0.0;
    }
  }
}
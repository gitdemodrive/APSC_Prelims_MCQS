import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/question.dart';
import '../models/user.dart' as app_models;
import '../models/quiz_result.dart';
import '../constants.dart';
import '../utils/error_handler.dart';

class SupabaseService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Authentication methods
  Future<void> signUp(String email, String password) async {
    await _supabaseClient.auth.signUp(email: email, password: password);
  }

  Future<void> signIn(String email, String password) async {
    await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  bool isAuthenticated() {
    return _supabaseClient.auth.currentSession != null;
  }

  String? getCurrentUserId() {
    return _supabaseClient.auth.currentUser?.id;
  }
  
  // Get the current session
  Session? getCurrentSession() {
    return _supabaseClient.auth.currentSession;
  }
  
  // Listen to auth state changes
  Stream<dynamic> get authStateChanges => _supabaseClient.auth.onAuthStateChange;
  
  // Get user profile data
  Future<app_models.User?> getUserProfile() async {
    final userId = getCurrentUserId();
    if (userId == null) return null;
    
    try {
      // Get user data from profiles table
      final data = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      // Get quiz scores for the user
      final scoresData = await _supabaseClient
          .from('quiz_scores')
          .select()
          .eq('user_id', userId);
      
      // Create user object with profile data and auth data
      final authUser = _supabaseClient.auth.currentUser;
      final user = app_models.User(
        id: userId,
        email: authUser?.email ?? '',
        createdAt: authUser?.createdAt != null ? DateTime.parse(authUser!.createdAt.toString()) : DateTime.now(),
        name: data['name'],
        phoneNumber: data['phone_number'],
        qualification: data['qualification'],
      );
      
      // Add quiz scores if available
      if (scoresData != null && scoresData.isNotEmpty) {
        user.quizScores = (scoresData as List<dynamic>).map((score) {
          return app_models.QuizScore(
            date: DateTime.parse(score['date']),
            score: score['score'],
            totalQuestions: score['total_questions'],
          );
        }).toList();
      }
      
      return user;
    } catch (e) {
      ErrorHandler.logError('getUserProfile', e, StackTrace.current);
      // If profile doesn't exist yet, create it and return basic user
      final authUser = _supabaseClient.auth.currentUser;
      if (authUser != null) {
        // Create an empty profile for the user
        try {
          await updateUserProfile();
          
          return app_models.User(
            id: authUser.id,
            email: authUser.email ?? '',
            createdAt: authUser.createdAt != null ? DateTime.parse(authUser.createdAt.toString()) : DateTime.now(),
          );
        } catch (profileError) {
          ErrorHandler.logError('getUserProfile - createProfile', profileError, StackTrace.current);
          return app_models.User(
            id: authUser.id,
            email: authUser.email ?? '',
            createdAt: authUser.createdAt != null ? DateTime.parse(authUser.createdAt.toString()) : DateTime.now(),
          );
        }
      }
      return null;
    }
  }
  
  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? qualification,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');
    
    final updates = {
      'id': userId,
      'name': name ?? '',
      'phone_number': phoneNumber ?? '',
      'qualification': qualification ?? '',
      'updated_at': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };
    
    try {
      await _supabaseClient.from('profiles').upsert(updates);
      debugPrint('Profile updated successfully');
    } catch (e) {
      ErrorHandler.logError('updateUserProfile', e, StackTrace.current);
      throw Exception('Failed to update profile');
    }
  }
  
  // Save quiz score
  Future<void> saveQuizScore({
    required DateTime date,
    required int score,
    required int totalQuestions,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');
    
    final scoreData = {
      'user_id': userId,
      'date': date.toIso8601String(),
      'score': score,
      'total_questions': totalQuestions,
      'created_at': DateTime.now().toIso8601String(),
    };
    
    await _supabaseClient.from('quiz_scores').insert(scoreData);
  }
  
  // Get average quiz score
  Future<double> getAverageQuizScore() async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');
    
    final scoresData = await _supabaseClient
        .from('quiz_scores')
        .select()
        .eq('user_id', userId);
    
    if (scoresData == null || (scoresData as List).isEmpty) {
      return 0.0;
    }
    
    double totalPercentage = 0.0;
    for (var score in scoresData) {
      final percentage = (score['score'] / score['total_questions']) * 100;
      totalPercentage += percentage;
    }
    
    return totalPercentage / scoresData.length;
  }

  // MCQ data methods
  Future<List<DateTime>> getAvailableDates() async {
    final data = await _supabaseClient
        .from('questions')
        .select('date')
        .order('date', ascending: false);

    final List<dynamic> dateData = data as List<dynamic>;
    final Set<String> uniqueDates = {};
    final List<DateTime> dates = [];

    for (var item in dateData) {
      final dateStr = item['date'] as String;
      if (uniqueDates.add(dateStr)) {
        dates.add(DateTime.parse(dateStr));
      }
    }

    return dates;
  }

  Future<List<Question>> getQuestionsByDate(DateTime date) async {
    final String dateStr = date.toIso8601String().split('T')[0];

    try {
      final data = await _supabaseClient
          .from('questions')
          .select()
          .eq('date', dateStr);

      if (data == null) {
        ErrorHandler.logError('getQuestionsByDate', 'No data returned', null);
        return [];
      }

      final List<dynamic> questionData = data as List<dynamic>;
      
      return questionData.map((json) => Question.fromJson(json)).toList();
    } catch (e) {
      ErrorHandler.logError('getQuestionsByDate', e, StackTrace.current);
      rethrow;
    }
  }
}
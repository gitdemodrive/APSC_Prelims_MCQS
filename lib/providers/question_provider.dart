import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../services/supabase_service.dart';

class QuestionProvider with ChangeNotifier {
  final SupabaseService _supabaseService;
  
  List<DateTime> _availableDates = [];
  List<Question> _questions = [];
  List<int?> _userAnswers = [];
  List<QuizResult> _quizResults = [];
  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _error;

  QuestionProvider(this._supabaseService);

  // Getters
  List<DateTime> get availableDates => _availableDates;
  List<Question> get questions => _questions;
  List<int?> get userAnswers => _userAnswers;
  List<QuizResult> get quizResults => _quizResults;
  DateTime? get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load available quiz dates
  Future<void> loadAvailableDates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dates = await _supabaseService.getAvailableDates();
      _availableDates = dates;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load questions for a specific date
  Future<bool> loadQuestions(DateTime date) async {
    _isLoading = true;
    _error = null;
    _selectedDate = date;
    notifyListeners();

    try {
      final questions = await _supabaseService.getQuestionsByDate(date);
      
      if (questions.isEmpty) {
        _error = 'No questions available for this date';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      _questions = questions;
      _userAnswers = List.filled(questions.length, null);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Set user's answer for a question
  void setAnswer(int questionIndex, int answerIndex) {
    if (questionIndex >= 0 && questionIndex < _userAnswers.length) {
      _userAnswers[questionIndex] = answerIndex;
      notifyListeners();
    }
  }

  // Submit all answers and calculate results
  Future<void> submitAnswers() async {
    _quizResults = [];
    
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final selectedAnswerIndex = _userAnswers[i] ?? -1;
      
      if (selectedAnswerIndex >= 0) {
        final isCorrect = selectedAnswerIndex == question.correctAnswerIndex;
        
        _quizResults.add(QuizResult(
          questionId: question.id,
          selectedAnswerIndex: selectedAnswerIndex,
          correctAnswerIndex: question.correctAnswerIndex,
        ));
      }
    }
    
    // Save quiz score to user profile
    try {
      final correctAnswers = _quizResults.where((result) => result.isCorrect).length;
      final totalQuestions = _questions.length;
      
      await _supabaseService.saveQuizScore(
        date: _selectedDate!,
        score: correctAnswers,
        totalQuestions: totalQuestions,
      );
    } catch (e) {
      _error = 'Failed to save quiz score: ${e.toString()}';
    }
    
    notifyListeners();
  }

  // Reset quiz state
  void resetQuiz() {
    _questions = [];
    _userAnswers = [];
    _quizResults = [];
    _selectedDate = null;
    _error = null;
    notifyListeners();
  }
}
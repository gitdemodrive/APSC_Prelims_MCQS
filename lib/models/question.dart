import 'dart:convert';

class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final DateTime date;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.date,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // Handle options which could be a JSON string or already a List
    List<String> parseOptions(dynamic options) {
      if (options is List) {
        return options.map((option) => option.toString()).toList();
      } else if (options is String) {
        // If options is a JSON string, parse it
        try {
           final List<dynamic> parsed = jsonDecode(options);
           return parsed.map((option) => option.toString()).toList();
         } catch (e) {
          print('Error parsing options: $e');
          return [options]; // Return the string as a single option if parsing fails
        }
      }
      print('Unexpected options format: $options');
      return []; // Return empty list as fallback
    }

    return Question(
      id: json['id'].toString(), // Convert to String to handle both String and int IDs
      question: json['question'] as String,
      options: parseOptions(json['options']),
      correctAnswerIndex: json['correct_answer_index'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correct_answer_index': correctAnswerIndex,
      'date': date.toIso8601String(),
    };
  }
}
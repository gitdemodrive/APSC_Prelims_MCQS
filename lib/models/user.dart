class User {
  final String id;
  final String email;
  final DateTime createdAt;
  String? name;
  String? phoneNumber;
  String? qualification;
  List<QuizScore>? quizScores;

  User({
    required this.id,
    required this.email,
    required this.createdAt,
    this.name,
    this.phoneNumber,
    this.qualification,
    this.quizScores,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<QuizScore>? quizScores;
    if (json['quiz_scores'] != null) {
      quizScores = (json['quiz_scores'] as List)
          .map((score) => QuizScore.fromJson(score))
          .toList();
    }

    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      name: json['name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      qualification: json['qualification'] as String?,
      quizScores: quizScores,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'phone_number': phoneNumber,
      'qualification': qualification,
      'quiz_scores': quizScores?.map((score) => score.toJson()).toList(),
    };
  }

  // Create a copy of the user with updated fields
  User copyWith({
    String? name,
    String? phoneNumber,
    String? qualification,
    List<QuizScore>? quizScores,
  }) {
    return User(
      id: this.id,
      email: this.email,
      createdAt: this.createdAt,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      qualification: qualification ?? this.qualification,
      quizScores: quizScores ?? this.quizScores,
    );
  }
}

class QuizScore {
  final DateTime date;
  final int score;
  final int totalQuestions;

  QuizScore({
    required this.date,
    required this.score,
    required this.totalQuestions,
  });

  factory QuizScore.fromJson(Map<String, dynamic> json) {
    return QuizScore(
      date: DateTime.parse(json['date'] as String),
      score: json['score'] as int,
      totalQuestions: json['total_questions'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'score': score,
      'total_questions': totalQuestions,
    };
  }

  // Calculate percentage score
  double get percentage => (score / totalQuestions) * 100;
}
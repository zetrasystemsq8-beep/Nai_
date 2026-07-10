enum ChallengeDifficulty { easy, medium, hard, expert }

extension ChallengeDifficultyValue on ChallengeDifficulty {
  int get coinReward {
    switch (this) {
      case ChallengeDifficulty.easy:
        return 10;
      case ChallengeDifficulty.medium:
        return 15;
      case ChallengeDifficulty.hard:
        return 25;
      case ChallengeDifficulty.expert:
        return 50;
    }
  }

  int get xpReward {
    switch (this) {
      case ChallengeDifficulty.easy:
        return 10;
      case ChallengeDifficulty.medium:
        return 20;
      case ChallengeDifficulty.hard:
        return 40;
      case ChallengeDifficulty.expert:
        return 80;
    }
  }

  String get label {
    switch (this) {
      case ChallengeDifficulty.easy:
        return 'Easy';
      case ChallengeDifficulty.medium:
        return 'Medium';
      case ChallengeDifficulty.hard:
        return 'Hard';
      case ChallengeDifficulty.expert:
        return 'Expert';
    }
  }
}

const List<String> challengeCategories = [
  'Nigeria',
  'Africa',
  'World',
  'Mathematics',
  'English',
  'Physics',
  'Chemistry',
  'Biology',
  'History',
  'Geography',
  'Programming',
  'AI',
  'Cybersecurity',
  'Business',
  'Finance',
  'Sports',
  'Movies',
  'Music',
  'Logic',
  'Riddles',
];

class Challenge {
  final String id;
  final String category;
  final ChallengeDifficulty difficulty;
  final String question;
  final String correctAnswer;
  final DateTime createdAt;

  const Challenge({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.question,
    required this.correctAnswer,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'difficulty': difficulty.name,
        'question': question,
        'correctAnswer': correctAnswer,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Challenge.fromJson(Map<dynamic, dynamic> json) => Challenge(
        id: json['id'] as String,
        category: json['category'] as String,
        difficulty: ChallengeDifficulty.values.firstWhere((d) => d.name == json['difficulty']),
        question: json['question'] as String,
        correctAnswer: json['correctAnswer'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

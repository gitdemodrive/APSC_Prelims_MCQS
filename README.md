# APSC Prelims Daily MCQs App

A Flutter application for APSC aspirants that delivers daily current affairs-based MCQs. The app allows users to sign up, log in, view available MCQ sets by date, take quizzes, and see their results.

## Features

- **Authentication**: Sign up and log in via email and password using Supabase Authentication
- **Dashboard**: View a day-wise list of MCQ sets
- **Quiz**: Take quizzes with multiple-choice questions
- **Results**: View detailed results with correct and incorrect answers

## Tech Stack

- **Frontend**: Flutter
- **Backend & Auth**: Supabase (PostgreSQL + Supabase Auth)

## Setup Instructions

### Prerequisites

- Flutter SDK (latest version)
- Supabase account

### Supabase Setup

1. Create a new Supabase project
2. Set up the following table in your Supabase database:

```sql
CREATE TABLE questions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  question TEXT NOT NULL,
  options JSONB NOT NULL,
  correct_answer_index INTEGER NOT NULL,
  date DATE NOT NULL
);

CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  name TEXT,
  phone_number TEXT,
  qualification TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE quiz_scores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  score INTEGER NOT NULL,
  total_questions INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

3. Enable Row Level Security (RLS) and configure appropriate policies
4. Get your Supabase URL and anon key from the API settings

### App Configuration

1. Open `lib/constants.dart`
2. Replace the placeholder values with your actual Supabase URL and anon key:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### Running the App

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

## Adding MCQs to Supabase

MCQs can be added manually via the Supabase dashboard or using the SQL editor. Here's an example SQL query to add a question:

```sql
INSERT INTO questions (question, options, correct_answer_index, date)
VALUES (
  'Which state in India has the longest coastline?',
  '["Gujarat", "Tamil Nadu", "Andhra Pradesh", "Kerala"]',
  0,
  '2023-06-12'
);
```

## Project Structure

- `lib/models/`: Data models
- `lib/providers/`: State management
- `lib/screens/`: UI screens
- `lib/services/`: API and backend services
- `lib/constants.dart`: App constants and configuration
- `lib/main.dart`: App entry point

## License

This project is licensed under the MIT License.

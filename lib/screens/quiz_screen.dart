import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/question_provider.dart';
import '../models/question.dart';
import '../utils/responsive_helper.dart';
import '../utils/ui_helper.dart';
import '../widgets/custom_button.dart';
import '../widgets/glassy_container.dart';
import '../widgets/responsive_scaffold.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;

  @override
  Widget build(BuildContext context) {
    final questionProvider = Provider.of<QuestionProvider>(context);
    final questions = questionProvider.questions;
    final currentQuestion = questions[_currentQuestionIndex];
    final userAnswers = questionProvider.userAnswers;

    return ResponsiveScaffold(
      title: 'Quiz - ${_currentQuestionIndex + 1}/${questions.length}',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          // Show confirmation dialog before exiting quiz
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Exit Quiz?'),
              content: const Text('Your progress will be lost. Are you sure you want to exit?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('EXIT'),
                ),
                ],
              ),
            );
          },
        ),
      body: Padding(
        padding: ResponsiveHelper.getResponsivePadding(context),
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / questions.length,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            
            // Question Card
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Text
                    GlassyContainer(
                      color: UIHelper.getGlassyColor(context),
                      borderRadius: UIHelper.getDefaultBorderRadius(context),
                      border: UIHelper.getGlassyBorder(context),
                      boxShadow: UIHelper.getDefaultBoxShadow(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${_currentQuestionIndex + 1}:',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentQuestion.question,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Answer Options
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentQuestion.options.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (ctx, index) {
                        final isSelected = userAnswers[_currentQuestionIndex] == index;
                        
                        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                        return GlassyContainer(
                          onTap: () {
                            setState(() {
                              questionProvider.setAnswer(_currentQuestionIndex, index);
                            });
                          },
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8)
                              : UIHelper.getGlassyColor(context),
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                  width: 1.5,
                                )
                              : UIHelper.getGlassyBorder(context),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: isSelected ? 10 : 5,
                              spreadRadius: 0,
                            ),
                          ],
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected 
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.surfaceVariant,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index), // A, B, C, D...
                                    style: TextStyle(
                                      color: isSelected 
                                          ? Theme.of(context).colorScheme.onPrimary
                                          : Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  currentQuestion.options[index],
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                                    color: isSelected 
                                        ? Theme.of(context).colorScheme.onPrimaryContainer
                                        : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous Button
                  if (_currentQuestionIndex > 0)
                    CustomButton(
                      text: 'Previous',
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex--;
                        });
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      width: 120,
                    )
                  else
                    const SizedBox(width: 120),
                    
                  // Next/Finish Button
                  CustomButton(
                    text: _currentQuestionIndex == questions.length - 1 ? 'Finish' : 'Next',
                    onPressed: () {
                      if (_currentQuestionIndex < questions.length - 1) {
                        setState(() {
                          _currentQuestionIndex++;
                        });
                      } else {
                        // Show loading indicator while submitting
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                        
                        // Submit answers and navigate to results
                        questionProvider.submitAnswers().then((_) {
                          // Close loading dialog
                          Navigator.of(context).pop();
                          // Navigate to results
                          GoRouter.of(context).go('/results');
                        });
                      }
                    },
                    icon: Icon(
                      _currentQuestionIndex == questions.length - 1 
                          ? Icons.check_circle 
                          : Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    width: 120,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
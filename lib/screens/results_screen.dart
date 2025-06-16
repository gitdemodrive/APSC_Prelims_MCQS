import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/question_provider.dart';
import '../utils/responsive_helper.dart';
import '../utils/ui_helper.dart';
import '../utils/animation_helper.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/glassy_container.dart';
import '../widgets/responsive_scaffold.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationHelper.createController(
      vsync: this,
      duration: const Duration(seconds: 1),
      repeat: false,
    );

    _scoreAnimation = AnimationHelper.createAnimation(
      controller: _animationController,
      begin: 0.0,
      end: 1.0,
      curve: Curves.easeOutCirc,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionProvider = Provider.of<QuestionProvider>(context);
    final questions = questionProvider.questions;
    final results = questionProvider.quizResults;

    // Calculate score
    final correctAnswers = results.where((result) => result.isCorrect).length;
    final totalQuestions = questions.length;
    final scorePercentage = (correctAnswers / totalQuestions) * 100;

    return ResponsiveScaffold(
      title: 'Quiz Results',
      leading: Container(), // To prevent back button
      body: Padding(
        padding: ResponsiveHelper.getResponsivePadding(context),
        child: Column(
          children: [
            // Score Card
            GlassyContainer(
              color: UIHelper.getGlassyColor(context),
              borderRadius: UIHelper.getDefaultBorderRadius(context),
              border: UIHelper.getGlassyBorder(context),
              boxShadow: UIHelper.getDefaultBoxShadow(),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Your Score',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        20,
                      ),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _scoreAnimation,
                        builder: (context, child) {
                          return SizedBox(
                            width:
                                ResponsiveHelper.getValueForScreenType<double>(
                                  context: context,
                                  mobile: 150,
                                  tablet: 180,
                                  desktop: 200,
                                ),
                            height:
                                ResponsiveHelper.getValueForScreenType<double>(
                                  context: context,
                                  mobile: 150,
                                  tablet: 180,
                                  desktop: 200,
                                ),
                            child: CircularProgressIndicator(
                              value:
                                  _scoreAnimation.value *
                                  (correctAnswers / totalQuestions),
                              strokeWidth: 12,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceVariant,
                              color: UIHelper.getScoreColor(scorePercentage),
                            ),
                          );
                        },
                      ),
                      Column(
                        children: [
                          Text(
                            '$correctAnswers/$totalQuestions',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                28,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${scorePercentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                20,
                              ),
                              fontWeight: FontWeight.w500,
                              color: UIHelper.getScoreColor(scorePercentage),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    UIHelper.getScoreMessage(scorePercentage),
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        18,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Results List
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Question Review',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          20,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: questions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (ctx, index) {
                        final question = questions[index];
                        final result = results[index];
                        final isCorrect = result.isCorrect;

                        return GlassyContainer(
                          color: isCorrect
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCorrect
                                ? Colors.green.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: UIHelper.getDefaultBoxShadow(),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Question Number and Status
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCorrect
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'Question ${index + 1}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            ResponsiveHelper.getResponsiveFontSize(
                                              context,
                                              14,
                                            ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    isCorrect
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: isCorrect
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isCorrect ? 'Correct' : 'Incorrect',
                                    style: TextStyle(
                                      color: isCorrect
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Question Text
                              Text(
                                question.question,
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        16,
                                      ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // User's Answer
                              _buildAnswerRow(
                                context,
                                'Your Answer:',
                                question.options[result.selectedAnswerIndex],
                                isCorrect ? Colors.green : Colors.red,
                              ),

                              // Show correct answer if user was wrong
                              if (!isCorrect) ...[
                                const SizedBox(height: 8),
                                _buildAnswerRow(
                                  context,
                                  'Correct Answer:',
                                  question.options[result.correctAnswerIndex],
                                  Colors.green,
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Back to Dashboard Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: CustomButton(
                text: 'Back to Dashboard',
                onPressed: () {
                  questionProvider.resetQuiz();
                  GoRouter.of(context).go('/');
                },
                icon: const Icon(Icons.home, color: Colors.white),
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerRow(
    BuildContext context,
    String label,
    String answer,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            answer,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

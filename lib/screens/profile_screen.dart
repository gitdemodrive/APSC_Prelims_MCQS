import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/responsive_helper.dart';
import '../utils/ui_helper.dart';
import '../widgets/custom_button.dart';
import '../widgets/glassy_container.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/responsive_scaffold.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _qualificationController = TextEditingController();
  bool _isEditing = false;
  double _averageScore = 0.0;
  bool _isLoadingAverage = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAverageScore();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Force a refresh of the user profile data from Supabase
    await authProvider.refreshUserProfile();
    
    final user = authProvider.currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = user.name ?? '';
        _phoneController.text = user.phoneNumber ?? '';
        _qualificationController.text = user.qualification ?? '';
      });
    }
  }

  Future<void> _loadAverageScore() async {
    setState(() {
      _isLoadingAverage = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null && user.quizScores != null && user.quizScores!.isNotEmpty) {
      double totalPercentage = 0;
      for (var score in user.quizScores!) {
        totalPercentage += (score.score / score.totalQuestions) * 100;
      }
      setState(() {
        _averageScore = totalPercentage / user.quizScores!.length;
        _isLoadingAverage = false;
      });
    } else {
      setState(() {
        _averageScore = 0;
        _isLoadingAverage = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user != null) {
        final updatedUser = user.copyWith(
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          qualification: _qualificationController.text,
        );

        await authProvider.updateUserProfile(
          name: updatedUser.name,
          phoneNumber: updatedUser.phoneNumber,
          qualification: updatedUser.qualification,
        );

        setState(() {
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final user = authProvider.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ResponsiveScaffold(
      title: 'Profile',
      body: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Profile',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Text(
                            user.name?.isNotEmpty == true
                                ? user.name![0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                // Theme toggle button
                IconButton(
                  icon: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                ),
                // Edit profile button
                IconButton(
                  icon: Icon(
                    _isEditing ? Icons.save : Icons.edit,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    if (_isEditing) {
                      _saveProfile();
                    } else {
                      setState(() {
                        _isEditing = true;
                      });
                    }
                  },
                ),
              ],
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: ResponsiveHelper.getResponsivePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email Card
                    GlassyContainer(
                      color: UIHelper.getGlassyColor(context),
                      borderRadius: UIHelper.getDefaultBorderRadius(context),
                      border: UIHelper.getGlassyBorder(context),
                      boxShadow: UIHelper.getDefaultBoxShadow(),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.email,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user.email ?? 'No email provided',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Profile Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Name Field
                          CustomTextField(
                            controller: _nameController,
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person),
                            enabled: _isEditing,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Phone Field
                          CustomTextField(
                            controller: _phoneController,
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone),
                            enabled: _isEditing,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Qualification Field
                          CustomTextField(
                            controller: _qualificationController,
                            labelText: 'Qualification',
                            prefixIcon: Icon(Icons.school),
                            enabled: _isEditing,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your qualification';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Performance Section
                    Text(
                      'Performance',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Average Score Card
                    GlassyContainer(
                      color: UIHelper.getGlassyColor(context),
                      borderRadius: UIHelper.getDefaultBorderRadius(context),
                      border: UIHelper.getGlassyBorder(context),
                      boxShadow: UIHelper.getDefaultBoxShadow(),
                      padding: const EdgeInsets.all(24),
                      child: _isLoadingAverage
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Average Score',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      _getScoreIcon(_averageScore),
                                      color: UIHelper.getScoreColor(_averageScore),
                                      size: 28,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: UIHelper.getScoreColor(_averageScore),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${_averageScore.toStringAsFixed(1)}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            UIHelper.getScoreMessage(_averageScore),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Based on ${user.quizScores?.length ?? 0} quizzes',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quiz History
                    if (user.quizScores != null && user.quizScores!.isNotEmpty)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Quiz History',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  // View all quiz history
                                },
                                icon: Icon(Icons.history, size: 16),
                                label: Text('View All'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GlassyContainer(
                            color: UIHelper.getGlassyColor(context),
                            borderRadius: UIHelper.getDefaultBorderRadius(context),
                            border: UIHelper.getGlassyBorder(context),
                            boxShadow: UIHelper.getDefaultBoxShadow(),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                ...user.quizScores!.take(3).map((score) {
                                  final percentage = (score.score / score.totalQuestions) * 100;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: UIHelper.getScoreColor(percentage),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${percentage.toInt()}%',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Quiz ${user.quizScores!.indexOf(score) + 1}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${score.score}/${score.totalQuestions} correct • ${DateFormat('MMM d, yyyy').format(score.date)}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Back to Dashboard Button
                    CustomButton(
                      text: 'Back to Dashboard',
                      onPressed: () {
                        GoRouter.of(context).go('/');
                      },
                      icon: const Icon(Icons.home, color: Colors.white),
                      width: double.infinity,
                      isOutlined: true,
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Using local method for icon selection since it's specific to this screen
  // Other score-related methods have been moved to UIHelper
  
  IconData _getScoreIcon(double percentage) {
    if (percentage >= 80) {
      return Icons.emoji_events;
    } else if (percentage >= 60) {
      return Icons.thumb_up;
    } else if (percentage >= 40) {
      return Icons.trending_up;
    } else {
      return Icons.refresh;
    }
  }
}
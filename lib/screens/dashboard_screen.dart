import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../providers/question_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/responsive_helper.dart';
import '../utils/animation_helper.dart';
import '../utils/ui_helper.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/glassy_container.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // Load available quiz dates when the screen initializes
    Future.microtask(() {
      Provider.of<QuestionProvider>(context, listen: false).loadAvailableDates();
    });
    
    // Initialize animation controller using the helper
    _animationController = AnimationHelper.createController(
      vsync: this,
      duration: const Duration(seconds: 10),
      repeat: true,
      reverse: true
    );
    
    _animation = AnimationHelper.createAnimation(
      controller: _animationController,
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionProvider = Provider.of<QuestionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final isMobile = ResponsiveHelper.isMobile(context);
    
    // Define colors for the glassy effect
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final backgroundColor = isDarkMode 
        ? const Color(0xFF121212) 
        : const Color(0xFFF5F5F5);
    final cardColor = isDarkMode 
        ? const Color(0xFF1E1E1E).withOpacity(0.7) 
        : Colors.white.withOpacity(0.7);

    return ResponsiveScaffold(
      title: 'APSC Prelims Daily MCQs',
      actions: [
        IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          ),
          onPressed: () {
            themeProvider.toggleTheme();
          },
        ),
        IconButton(
          icon: const Icon(Icons.account_circle),
          tooltip: 'Profile',
          onPressed: () {
            GoRouter.of(context).go('/profile');
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () async {
            await authProvider.signOut();
          },
        ),
      ],
      bottomNavigationBar: isMobile ? _buildDynamicIslandNavBar(context, isDarkMode) : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
                ? [backgroundColor, Color(0xFF1A1A2E)] 
                : [Color(0xFFE8F0FE), Color(0xFFD4E4FF)],
            stops: const [0.3, 1.0],
          ),
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: [
                // Animated background shapes for visual interest
                Positioned(
                  top: AnimationHelper.getFloatingOffset(_animation, 50),
                  right: -30,
                  child: _buildBlurredCircle(150, primaryColor.withOpacity(0.1)),
                ),
                Positioned(
                  bottom: AnimationHelper.getFloatingOffset(_animation, 100, amplitude: -30),
                  left: -20,
                  child: _buildBlurredCircle(120, secondaryColor.withOpacity(0.1)),
                ),
                // Main content
                Padding(
                  padding: ResponsiveHelper.getResponsivePadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with welcome message
                      _buildWelcomeHeader(context, authProvider),
                      
                      const SizedBox(height: 24),
                      
                      // Available Quizzes Section
                      Text(
                        'Available Quizzes',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 22),
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 16),

                      // Loading or Error State
                      if (questionProvider.isLoading)
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (questionProvider.error != null)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Error: ${questionProvider.error}',
                                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                CustomButton(
                                  text: 'Retry',
                                  onPressed: () {
                                    questionProvider.loadAvailableDates();
                                  },
                                  icon: const Icon(Icons.refresh, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        )
                      // Quiz List
                      else if (questionProvider.availableDates.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Text('No quizzes available at the moment.'),
                          ),
                        )
                      else
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              await questionProvider.loadAvailableDates();
                            },
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: ResponsiveHelper.getValueForScreenType<int>(
                                  context: context,
                                  mobile: 1,
                                  tablet: 2,
                                  desktop: 3,
                                ),
                                childAspectRatio: 1.5,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: questionProvider.availableDates.length,
                              itemBuilder: (ctx, index) {
                                final date = questionProvider.availableDates[index];
                                final formattedDate = DateFormat('dd MMMM, yyyy').format(date);
                                
                                return _buildGlassyQuizCard(
                                  context, 
                                  formattedDate, 
                                  date, 
                                  questionProvider,
                                  cardColor,
                                  isDarkMode
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildWelcomeHeader(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    // Use name if available and not empty, otherwise use email address
    final String displayName;
    if (user?.name != null && user!.name!.isNotEmpty) {
      displayName = user.name!;
    } else {
      displayName = user?.email.split('@').first ?? 'Student';
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayName,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGlassyQuizCard(BuildContext context, String formattedDate, DateTime date, 
      QuestionProvider questionProvider, Color cardColor, bool isDarkMode) {
    return GlassyContainer(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      border: UIHelper.getGlassyBorder(context),
      boxShadow: UIHelper.getDefaultBoxShadow(),
      onTap: () async {
        // Load questions for the selected date
        final success = await questionProvider.loadQuestions(date);
        if (success && mounted) {
          // Navigate to the quiz screen using GoRouter
          GoRouter.of(context).go('/quiz');
        }
      },
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.quiz_rounded,
              size: ResponsiveHelper.getValueForScreenType<double>(
                context: context,
                mobile: 36,
                tablet: 42,
                desktop: 48,
              ),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_outline,
                size: 18,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Start Quiz',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildDynamicIslandNavBar(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
      child: GlassyContainer(
        height: 64,
        color: UIHelper.getGlassyColor(context),
        borderRadius: BorderRadius.circular(32),
        border: UIHelper.getGlassyBorder(context),
        boxShadow: UIHelper.getDefaultBoxShadow(),
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home_rounded, 'Home', isDarkMode),
            _buildNavItem(1, Icons.history_rounded, 'History', isDarkMode),
            _buildNavItem(2, Icons.person_rounded, 'Profile', isDarkMode),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavItem(int index, IconData icon, String label, bool isDarkMode) {
    final isSelected = index == _selectedIndex;
    final primaryColor = Theme.of(this.context).colorScheme.primary;
    final secondaryColor = isDarkMode ? Colors.white70 : Colors.black54;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        
        // Handle navigation
        switch (index) {
          case 0: // Home
            if (GoRouterState.of(this.context).matchedLocation != '/') {
              GoRouter.of(this.context).go('/');
            }
            break;
          case 1: // History - You might need to create this screen
            // GoRouter.of(this.context).go('/history');
            break;
          case 2: // Profile
            GoRouter.of(this.context).go('/profile');
            break;
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected ? BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
        ) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : secondaryColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? primaryColor : secondaryColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBlurredCircle(double size, Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Apply breathing effect to the circle size
        final animatedSize = AnimationHelper.getBreathingSize(_animation, size, amplitude: 0.05);
        
        return GlassyContainer(
          width: animatedSize,
          height: animatedSize,
          color: color,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(animatedSize / 2),
          blurSigma: 5.0,
          border: null,
          boxShadow: null,
          child: const SizedBox(),
        );
      },
    );
  }
}
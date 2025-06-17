import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';
import '../utils/responsive_helper.dart';
import '../utils/animation_helper.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/glassy_container.dart';
import '../widgets/responsive_scaffold.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _animation;

  // 0 = Welcome, 1 = Login, 2 = Register
  int _currentScreen = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationHelper.createController(
      vsync: this,
      duration: const Duration(seconds: 20),
      autoStart: true,
      repeat: true,
      reverse: true,
    );

    _animation = AnimationHelper.createAnimation(
      controller: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    setState(() {
      _currentScreen = 1;
    });
  }

  void _navigateToRegister() {
    setState(() {
      _currentScreen = 2;
    });
  }

  void _navigateToWelcome() {
    setState(() {
      _currentScreen = 0;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    bool success = await authProvider.signIn(email, password);

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful!')));
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    bool success = await authProvider.signUp(email, password);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
      _navigateToLogin();
    }
  }

  // Background animation bubbles
  Widget _buildAnimatedBackground(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF304FFE), // Bright blue
                    const Color(0xFF1A237E), // Deep indigo
                  ],
                ),
              ),
            ),

            // Subtle pattern overlay
            Opacity(
              opacity: 0.05,
              child: SizedBox.expand(
                child: Stack(
                  children: List.generate(20, (index) {
                    final x = (index % 5) * 20.0;
                    final y = (index ~/ 5) * 20.0;
                    return Positioned(
                      left: x,
                      top: y,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Animated bubble 1 (top left)
            Positioned(
              left: AnimationHelper.getFloatingOffset(
                _animation,
                -80,
                amplitude: 60,
              ),
              top: AnimationHelper.getFloatingOffset(
                _animation,
                -80,
                amplitude: 60,
              ),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.blue.shade300.withOpacity(0.3),
                      Colors.blue.shade300.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Animated bubble 2 (bottom right)
            Positioned(
              right: AnimationHelper.getFloatingOffset(
                _animation,
                -60,
                amplitude: 40,
              ),
              bottom: AnimationHelper.getFloatingOffset(
                _animation,
                -40,
                amplitude: 40,
              ),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.blue.shade200.withOpacity(0.2),
                      Colors.blue.shade200.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Animated bubble 3 (bottom left)
            Positioned(
              left: AnimationHelper.getFloatingOffset(
                _animation,
                40,
                amplitude: 30,
              ),
              bottom: AnimationHelper.getFloatingOffset(
                _animation,
                80,
                amplitude: 40,
              ),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.blue.shade100.withOpacity(0.2),
                      Colors.blue.shade100.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Welcome screen
  Widget _buildWelcomeScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Person with laptop illustration
          SvgPicture.asset(
            'assets/images/welcome_illustration.svg',
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 30),

          // Welcome text
          Text(
            'Welcome to',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4042e3),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'APSC Master!',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4042e3),
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Prepare with us and Practice Daily Current Affairs MCQ\'s and Subject-wise Mock test.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                color: Colors.black87,
              ),
            ),
          ),
          const Spacer(),

          // Login button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF4042e3),
              ),
              child: CustomButton(
                text: 'Login',
                onPressed: _navigateToLogin,
                width: double.infinity,
                height: 50,
                backgroundColor: Colors.transparent,
                textColor: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Register button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: CustomButton(
                text: 'Register',
                onPressed: _navigateToRegister,
                width: double.infinity,
                height: 50,
                isOutlined: false,
                backgroundColor: Colors.transparent,
                textColor: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Login screen
  Widget _buildLoginScreen(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: const Color(0xFF4042e3)),
                    onPressed: _navigateToWelcome,
                  ),
                ),
                const SizedBox(height: 20),

                // Login title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Login here',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        24,
                      ),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4042e3),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Welcome back text
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Welcome back you\'ve been missed!',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        14,
                      ),
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Email field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: CustomTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot your password?',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          12,
                        ),
                        color: const Color(0xFF4042e3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Error message
                if (authProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      authProvider.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Sign in button
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF4042e3),
                  ),
                  child: CustomButton(
                    text: 'Sign in',
                    onPressed: _login,
                    isLoading: authProvider.isLoading,
                    width: double.infinity,
                    height: 50,
                    backgroundColor: Colors.transparent,
                    textColor: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 24),

                // Create new account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Create new account',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          14,
                        ),
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: _navigateToRegister,
                      child: const Text('Sign up'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              14,
                            ),
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Social login buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset(
                          'assets/icons/google_icon.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(Colors.grey.shade700, BlendMode.srcIn),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset(
                          'assets/icons/facebook_icon.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(Colors.grey.shade700, BlendMode.srcIn),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset(
                          'assets/icons/apple_icon.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(Colors.grey.shade700, BlendMode.srcIn),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Register screen
  Widget _buildRegisterScreen(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: const Color(0xFF4042e3)),
                    onPressed: _navigateToWelcome,
                  ),
                ),
                const SizedBox(height: 20),

                // Create Account title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        24,
                      ),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4042e3),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Create account subtitle
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Create an account so you can explore all the MCQ\'s Questions',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        14,
                      ),
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Email field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: CustomTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Error message
                if (authProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      authProvider.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Sign up button
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF4042e3),
                  ),
                  child: CustomButton(
                    text: 'Sign up',
                    onPressed: _register,
                    isLoading: authProvider.isLoading,
                    width: double.infinity,
                    height: 50,
                    backgroundColor: Colors.transparent,
                    textColor: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 24),

                // Already have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          14,
                        ),
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: _navigateToLogin,
                      child: Text('Sign in', style: TextStyle(color: const Color(0xFF4042e3))),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              14,
                            ),
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Social login buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset(
                          'assets/icons/google_icon.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(Colors.grey.shade700, BlendMode.srcIn),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset(
                          'assets/icons/facebook_icon.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(Colors.grey.shade700, BlendMode.srcIn),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset(
                          'assets/icons/apple_icon.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(Colors.grey.shade700, BlendMode.srcIn),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Social login button
  Widget _socialLoginButton(String iconPath, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(Colors.grey.shade700, BlendMode.srcIn),
        ),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: SvgPicture.asset(
                'assets/images/pattern.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content based on current screen
          if (_currentScreen == 0)
            _buildWelcomeScreen(context)
          else if (_currentScreen == 1)
            _buildLoginScreen(context)
          else
            _buildRegisterScreen(context),
        ],
      ),
    );
  }
}

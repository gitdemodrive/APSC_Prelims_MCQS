import 'package:flutter/material.dart';

/// A utility class for standardized error handling across the app
class ErrorHandler {
  /// Formats error messages for display to users
  /// Removes technical details and provides user-friendly messages
  static String formatErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';
    
    final errorStr = error.toString();
    
    // Handle Supabase authentication errors
    if (errorStr.contains('Invalid login credentials')) {
      return 'Invalid email or password';
    } else if (errorStr.contains('Email not confirmed')) {
      return 'Please confirm your email address';
    } else if (errorStr.contains('User already registered')) {
      return 'An account with this email already exists';
    } else if (errorStr.contains('Password should be at least')) {
      return 'Password is too short';
    } else if (errorStr.contains('network')) {
      return 'Network error. Please check your connection';
    }
    
    // Handle database errors
    if (errorStr.contains('database') || errorStr.contains('query')) {
      return 'Database error. Please try again later';
    }
    
    // Handle general errors
    if (errorStr.length > 100) {
      // Truncate very long error messages
      return 'An error occurred. Please try again later';
    }
    
    return errorStr;
  }

  /// Logs errors to console in development mode
  /// In production, this could be extended to log to a service
  static void logError(String source, dynamic error, StackTrace? stackTrace) {
    // In production, remove or modify this to use a proper logging service
    debugPrint('ERROR in $source: ${error.toString()}');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Shows a snackbar with an error message
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows a dialog with an error message
  static Future<void> showErrorDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
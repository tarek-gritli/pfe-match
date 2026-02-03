import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>()..clearError();
    final success = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // On web, navigate to specific routes
      if (kIsWeb) {
        if (auth.profileCompleted) {
          if (auth.userType == 'student') {
            Navigator.pushReplacementNamed(context, AppRoutes.studentProfile);
          } else if (auth.userType == 'enterprise') {
            Navigator.pushReplacementNamed(context, AppRoutes.enterpriseProfile);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        } else {
          if (auth.userType == 'student') {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.createStudentProfile,
            );
          } else if (auth.userType == 'enterprise') {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.createEnterpriseProfile,
            );
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        }
      }
      // On mobile, the Consumer2 in main.dart will automatically show MainScreen
      // when auth.isAuthenticated becomes true, so no navigation needed
    }
  }

  void _togglePasswordVisibility() =>
      setState(() => _showPassword = !_showPassword);

  void _navigateToRegister() {
    context.read<AuthProvider>().clearError();
    Navigator.pushReplacementNamed(context, AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildErrorBanner(),
                    _buildForm(),
                    const SizedBox(height: 24),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'PFE Match',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Welcome back',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Sign in to your account',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Selector<AuthProvider, String?>(
      selector: (_, auth) => auth.error,
      builder: (_, error, __) {
        if (error == null) return const SizedBox.shrink();
        return _ErrorBanner(
          message: error,
          onDismiss: () => context.read<AuthProvider>().clearError(),
        );
      },
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outlined,
            obscureText: !_showPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              onPressed: _togglePasswordVisibility,
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 8),
          _buildForgotPassword(),
          const SizedBox(height: 24),
          _buildLoginButton(),
          const SizedBox(height: 16),
          _buildDivider(),
          const SizedBox(height: 16),
          _buildGoogleButton(),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Forgot password?',
          style: TextStyle(color: AppColors.primary, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Selector<AuthProvider, bool>(
      selector: (_, auth) => auth.isLoading,
      builder: (_, isLoading, __) => CustomButton(
        text: 'Sign In',
        isLoading: isLoading,
        onPressed: _handleLogin,
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or', style: TextStyle(color: Colors.grey[600])),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return CustomButton(
      text: 'Continue with Google',
      isOutlined: true,
      icon: const Icon(Icons.g_mobiledata, size: 24),
      onPressed: () {},
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: _navigateToRegister,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Sign up',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }
}

/// Reusable Error Banner Widget
class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_getIcon(), color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getDisplayMessage(),
              style: const TextStyle(color: AppColors.error, fontSize: 14),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close, size: 18, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  String _getDisplayMessage() {
    const errorMap = {
      'Invalid email or password':
          'The email or password you entered is incorrect.',
      'Account is inactive':
          'Your account has been deactivated. Contact support.',
      'Connection': 'No internet connection. Please try again.',
      'timeout': 'Request timed out. Please try again.',
    };

    for (final entry in errorMap.entries) {
      if (message.contains(entry.key)) return entry.value;
    }
    return message;
  }

  IconData _getIcon() {
    if (message.contains('Invalid email or password')) {
      return Icons.lock_outline;
    }
    if (message.contains('Account is inactive')) return Icons.block;
    if (message.contains('Connection')) return Icons.wifi_off;
    return Icons.error_outline;
  }
}

import 'package:flutter/material.dart';
import 'package:mobile/core/config/routes.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

enum AccountType { student, enterprise }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  AccountType? _accountType;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String? _successMessage;

  final _formKey = GlobalKey<FormState>();

  // Student controllers
  final _studentFirstNameController = TextEditingController();
  final _studentLastNameController = TextEditingController();
  final _studentEmailController = TextEditingController();
  final _studentUniversityController = TextEditingController();
  final _studentPasswordController = TextEditingController();
  final _studentConfirmPasswordController = TextEditingController();

  // Enterprise controllers
  final _companyNameController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _industryController = TextEditingController();
  final _enterprisePasswordController = TextEditingController();
  final _enterpriseConfirmPasswordController = TextEditingController();

  final List<Map<String, dynamic>> _passwordRequirements = [
    {'label': 'At least 8 characters', 'check': (String p) => p.length >= 8},
    {
      'label': 'Contains uppercase letter',
      'check': (String p) => RegExp(r'[A-Z]').hasMatch(p),
    },
    {
      'label': 'Contains lowercase letter',
      'check': (String p) => RegExp(r'[a-z]').hasMatch(p),
    },
    {
      'label': 'Contains a number',
      'check': (String p) => RegExp(r'[0-9]').hasMatch(p),
    },
  ];

  String get _currentPassword => _accountType == AccountType.student
      ? _studentPasswordController.text
      : _enterprisePasswordController.text;

  @override
  void dispose() {
    _studentFirstNameController.dispose();
    _studentLastNameController.dispose();
    _studentEmailController.dispose();
    _studentUniversityController.dispose();
    _studentPasswordController.dispose();
    _studentConfirmPasswordController.dispose();
    _companyNameController.dispose();
    _businessEmailController.dispose();
    _industryController.dispose();
    _enterprisePasswordController.dispose();
    _enterpriseConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleStudentSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.registerStudent(
      firstName: _studentFirstNameController.text,
      lastName: _studentLastNameController.text,
      email: _studentEmailController.text,
      university: _studentUniversityController.text,
      password: _studentPasswordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.createStudentProfile);
    }
  }

  void _navigateToLogin() {
    context.read<AuthProvider>().clearError();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  Future<void> _handleEnterpriseSubmit() async {
  if (!_formKey.currentState!.validate()) return;

  final authProvider = context.read<AuthProvider>();
  final success = await authProvider.registerEnterprise(
    companyName: _companyNameController.text,
    email: _businessEmailController.text,
    industry: _industryController.text,
    password: _enterprisePasswordController.text,
  );

  if (!success) return;

  Navigator.of(context).pushReplacementNamed(
    AppRoutes.createEnterpriseProfile,
  );
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
                    // Logo
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ).createShader(bounds),
                      child: const Text(
                        'PFE Match',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Create an account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose your account type to get started',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    // Messages
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        if (_successMessage != null) {
                          return _buildMessage(
                            _successMessage!,
                            AppColors.success,
                          );
                        }
                        if (auth.error != null) {
                          print('Auth Error: ${auth.error}');
                          return _buildMessage(auth.error!, AppColors.error);
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Account Type Selection
                    Row(
                      children: [
                        Expanded(
                          child: _AccountTypeButton(
                            icon: Icons.school_outlined,
                            label: 'Student',
                            isSelected: _accountType == AccountType.student,
                            onTap: () => setState(
                              () => _accountType = AccountType.student,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AccountTypeButton(
                            icon: Icons.business_outlined,
                            label: 'Enterprise',
                            isSelected: _accountType == AccountType.enterprise,
                            onTap: () => setState(
                              () => _accountType = AccountType.enterprise,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Forms
                    if (_accountType == AccountType.student)
                      _buildStudentForm(),
                    if (_accountType == AccountType.enterprise)
                      _buildEnterpriseForm(),
                    if (_accountType == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'Select an account type above',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: () {
                            _navigateToLogin();
                          },
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(message, style: TextStyle(color: color)),
    );
  }

  Widget _buildStudentForm() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _studentFirstNameController,
                label: 'First Name',
                hint: 'Enter your first name',
                prefixIcon: Icons.person_outline,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              CustomTextField(
                controller: _studentLastNameController,
                label: 'Last Name',
                hint: 'Enter your last name',
                prefixIcon: Icons.person_outline,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _studentEmailController,
                label: 'Email',
                hint: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v))
                    return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _studentPasswordController,
                label: 'Password',
                hint: 'Create a password',
                prefixIcon: Icons.lock_outline,
                obscureText: !_showPassword,
                onChanged: (_) => setState(() {}),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _studentConfirmPasswordController,
                label: 'Confirm Password',
                hint: 'Confirm your password',
                prefixIcon: Icons.lock_outline,
                obscureText: !_showConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 20,
                  ),
                  onPressed: () => setState(
                    () => _showConfirmPassword = !_showConfirmPassword,
                  ),
                ),
                validator: (v) => v != _studentPasswordController.text
                    ? 'Passwords do not match'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildPasswordRequirements(),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Create Account',
                isLoading: auth.isLoading,
                onPressed: _handleStudentSubmit,
              ),
              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Sign up with Google',
                isOutlined: true,
                icon: const Icon(Icons.g_mobiledata, size: 24),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnterpriseForm() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _companyNameController,
                label: 'Company Name',
                hint: 'Enter company name',
                prefixIcon: Icons.business_outlined,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _businessEmailController,
                label: 'Business Email',
                hint: 'Enter business email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v))
                    return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _industryController,
                label: 'Industry',
                hint: 'e.g., Technology, Finance',
                prefixIcon: Icons.category_outlined,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _enterprisePasswordController,
                label: 'Password',
                hint: 'Create a password',
                prefixIcon: Icons.lock_outline,
                obscureText: !_showPassword,
                onChanged: (_) => setState(() {}),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _enterpriseConfirmPasswordController,
                label: 'Confirm Password',
                hint: 'Confirm your password',
                prefixIcon: Icons.lock_outline,
                obscureText: !_showConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 20,
                  ),
                  onPressed: () => setState(
                    () => _showConfirmPassword = !_showConfirmPassword,
                  ),
                ),
                validator: (v) => v != _enterprisePasswordController.text
                    ? 'Passwords do not match'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildPasswordRequirements(),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Create Account',
                isLoading: auth.isLoading,
                onPressed: _handleEnterpriseSubmit,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPasswordRequirements() {
    return Column(
      children: _passwordRequirements.map((req) {
        final isMet = req['check'](_currentPassword);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(
                isMet ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 16,
                color: isMet ? AppColors.success : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                req['label'],
                style: TextStyle(
                  fontSize: 12,
                  color: isMet ? AppColors.success : Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or', style: TextStyle(color: Colors.grey[600])),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }
}

class _AccountTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTypeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

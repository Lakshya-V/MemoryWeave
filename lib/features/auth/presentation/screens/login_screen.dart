import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/accessible_button.dart';
import '../../../../core/widgets/accessible_card.dart';
import '../widgets/login_text_field.dart';
import '../widgets/memory_weave_logo.dart';
import '../../../home/presentation/screens/patient_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController(text: 'eleanor_hart');
  final TextEditingController _passwordController = TextEditingController(text: '••••••••');
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const PatientHomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.containerMargin),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const MemoryWeaveLogo(size: 90.0),
                  const SizedBox(height: 16.0),
                  const Text(
                    AppStrings.tagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Atkinson Hyperlegible Next',
                      fontSize: 28.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  AccessibleCard(
                    padding: const EdgeInsets.all(24.0),
                    backgroundColor: AppColors.surfaceContainerLowest,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LoginTextField(
                          label: AppStrings.username,
                          hintText: AppStrings.enterUsername,
                          controller: _usernameController,
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: AppDimensions.stackGap),
                        LoginTextField(
                          label: AppStrings.password,
                          hintText: AppStrings.enterPassword,
                          controller: _passwordController,
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          isPasswordVisible: _isPasswordVisible,
                          onTogglePasswordVisibility: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        const SizedBox(height: 28.0),
                        AccessibleButton(
                          text: AppStrings.logIn,
                          suffixIcon: Icons.login,
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.onPrimary,
                          onPressed: _handleLogin,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

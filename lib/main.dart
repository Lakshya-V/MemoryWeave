import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/elder_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/patient_home_screen.dart';
import 'features/quiz/presentation/screens/interactive_quiz_screen.dart';
import 'features/caregiver_dashboard/presentation/screens/caregiver_dashboard_screen.dart';
import 'features/add_memory/presentation/screens/add_family_memory_screen.dart';
import 'features/questionnaire_preview/presentation/screens/questionnaire_preview_screen.dart';
import 'features/memory_details/presentation/screens/memory_details_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MemoryWeaveApp());
}

/// Wraps a screen with the elder-specific theme (bigger text, plainer
/// white background) without touching the app's global theme, which
/// caregiver screens continue to use as-is.
class _ElderThemed extends StatelessWidget {
  final Widget child;
  const _ElderThemed({required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(data: ElderTheme.theme, child: child);
  }
}

class MemoryWeaveApp extends StatelessWidget {
  const MemoryWeaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        // Elder-facing screens: extra-large text, plain white background.
        '/home': (context) => const _ElderThemed(child: PatientHomeScreen()),
        '/quiz': (context) => const _ElderThemed(child: InteractiveQuizScreen()),
        // Caregiver-facing screens: keep the standard accessible theme.
        '/caregiver': (context) => const CaregiverDashboardScreen(),
        '/add-memory': (context) => const AddFamilyMemoryScreen(),
        '/questionnaire-preview': (context) => const QuestionnairePreviewScreen(),
        '/memory-details': (context) => const MemoryDetailsScreen(),
      },
    );
  }
}
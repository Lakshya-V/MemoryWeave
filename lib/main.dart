import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
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
        '/home': (context) => const PatientHomeScreen(),
        '/quiz': (context) => const InteractiveQuizScreen(),
        '/caregiver': (context) => const CaregiverDashboardScreen(),
        '/add-memory': (context) => const AddFamilyMemoryScreen(),
        '/questionnaire-preview': (context) => const QuestionnairePreviewScreen(),
        '/memory-details': (context) => const MemoryDetailsScreen(),
      },
    );
  }
}

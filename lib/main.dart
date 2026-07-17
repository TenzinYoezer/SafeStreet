import 'package:flutter/material.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/submit_report_screen.dart';
import 'screens/my_reports_screen.dart';
import 'screens/report_details_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/council_main_screen.dart';
import 'screens/resident_home_screen.dart';
import 'theme/app_theme.dart';
import 'screens/manage_reports_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/map_screen.dart';
import 'screens/security_reports_screen.dart';
import 'screens/security_main_screen.dart';
import 'screens/forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SafeStreetApp());
}

class SafeStreetApp extends StatelessWidget {
  const SafeStreetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeStreet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),

        RegisterScreen.routeName: (context) => const RegisterScreen(),

        HomeScreen.routeName: (context) => const HomeScreen(),

        SubmitReportScreen.routeName: (context) => const SubmitReportScreen(),

        ForgotPasswordScreen.routeName: (context) =>
            const ForgotPasswordScreen(),

        MyReportsScreen.routeName: (context) => const MyReportsScreen(),

        '/report-details': (context) => const ReportDetailsScreen(),

        ProfileScreen.routeName: (context) => const ProfileScreen(),

        SettingsScreen.routeName: (context) => const SettingsScreen(),

        EditProfileScreen.routeName: (context) => const EditProfileScreen(),

        // NEW ROLE DASHBOARDS
        '/residentHome': (context) => const ResidentHomeScreen(),

        '/securityDashboard': (context) => const SecurityMainScreen(),

        '/councilDashboard': (context) => CouncilMainScreen(),

        '/manageReports': (context) => const ManageReportsScreen(),

        '/securityReports': (context) => const SecurityReportsScreen(),

        '/mapScreen': (context) => const MapScreen(),
      },
    );
  }
}

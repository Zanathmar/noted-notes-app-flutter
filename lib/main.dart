import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/supabase_config.dart';
import 'screens/auth_screen.dart';
import 'screens/notes_list_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    
    // If user is logged in, go to notes
    if (supabase.auth.currentSession != null) {
      return const NotesListScreen();
    }
    
    // If onboarding not complete, show onboarding
    if (!onboardingComplete) {
      return const OnboardingScreen();
    }
    
    // Otherwise show auth
    return const AuthScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noted',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF54ACE3),
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          }
          return snapshot.data ?? const OnboardingScreen();
        },
      ),
    );
  }
}
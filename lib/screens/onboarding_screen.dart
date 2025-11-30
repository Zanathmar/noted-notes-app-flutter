import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/auth_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnBoardingSlider(
      finishButtonText: 'Get Started',
      onFinish: () => _completeOnboarding(context),
      finishButtonStyle: const FinishButtonStyle(
        backgroundColor: Color(0xFF6B9BD1), // Soft blue for better contrast
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
      ),
      skipTextButton: const Text(
        'Skip',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF5A7C9C), // Muted blue-gray
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Text(
        'Sign In',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF5A7C9C), // Muted blue-gray
          fontWeight: FontWeight.w600,
        ),
      ),
      trailingFunction: () => _completeOnboarding(context),
      controllerColor: const Color(0xFF6B9BD1), // Soft blue for pagination dots
      totalPage: 3,
      headerBackgroundColor: const Color(0xFFF5F7FA), // Light cool gray background
      pageBackgroundColor: const Color(0xFFF5F7FA), // Light cool gray background
      background: [
        // Page 1 - Welcome
        Center(
          child: Image.asset(
            'assets/splash1.png',
            height: 300,
            fit: BoxFit.contain,
          ),
        ),
        // Page 2 - Create & Organize
        Center(
          child: Image.asset(
            'assets/splash2.png',
            height: 300,
            fit: BoxFit.contain,
          ),
        ),
        // Page 3 - Cloud Sync
        Center(
          child: Image.asset(
            'assets/splash3.png',
            height: 300,
            fit: BoxFit.contain,
          ),
        ),
      ],
      speed: 1.8,
      pageBodies: [
        // Page 1 Body
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 380),
              Text(
                'Welcome to Noted',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50), // Dark blue-gray for better contrast
                ),
              ),
              SizedBox(height: 20),
              Text(
                'A clean and simple space to capture your thoughts, ideas, and reminders — anytime you need.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5A7C9C), // Muted blue-gray
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        // Page 2 Body
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 380),
              Text(
                'Write Without Limits',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50), // Dark blue-gray for better contrast
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Create, edit, and organize your notes effortlessly with a smooth, distraction-free experience.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5A7C9C), // Muted blue-gray
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        // Page 3 Body
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 380),
              Text(
                'Your Notes, Everywhere',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50), // Dark blue-gray for better contrast
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Automatically synced to the cloud — access your notes securely from any device, anytime.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5A7C9C), // Muted blue-gray
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
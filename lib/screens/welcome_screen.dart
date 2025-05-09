import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_card_tracker/widgets/custom_button.dart';
import 'package:pokemon_card_tracker/utils/constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or image here
              Icon(
                Icons.catching_pokemon,
                size: 100,
                color: AppColors.primaryBlue,
              ),
              SizedBox(height: 24),
              Text(
                AppStrings.welcome,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48),
              CustomButton(
                text: AppStrings.login,
                onPressed: () => context.go('/login'),
              ),
              SizedBox(height: 16),
              CustomButton(
                text: AppStrings.signup,
                onPressed: () => context.go('/signup'),
                backgroundColor: Colors.grey[300],
                textColor: Colors.black87,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
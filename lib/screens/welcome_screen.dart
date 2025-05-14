import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_card_tracker/widgets/custom_button.dart';
import 'package:pokemon_card_tracker/utils/constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Subtle gradient background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[300]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo with subtle shadow
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.catching_pokemon,
                          size: 80,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    );
                  },
                ),
                
                SizedBox(height: 36),
                
                // Welcome text with animated underline
                Column(
                  children: [
                    Text(
                      AppStrings.welcome,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    // Animated underline
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 60),
                      duration: Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (context, double width, child) {
                        return Container(
                          height: 3,
                          width: width,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                // Subtitle
                Text(
                  'Track your Pokémon card collection',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 60),
                
                // Cards illustration (minimalist)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < 3; i++)
                      Transform.translate(
                        offset: Offset(i * -15.0, 0),
                        child: Transform.rotate(
                          angle: (i - 1) * 0.1,
                          child: Container(
                            height: 80,
                            width: 55,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.catching_pokemon,
                                size: 20,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                SizedBox(height: 60),
                
                // Login button
                CustomButton(
                  text: AppStrings.login,
                  onPressed: () => context.go('/login'),
                ),
                
                SizedBox(height: 16),
                
                // Sign up button
                CustomButton(
                  text: AppStrings.signup,
                  onPressed: () => context.go('/signup'),
                  backgroundColor: Colors.grey[300],
                  textColor: Colors.black87,
                ),
                
                SizedBox(height: 24),
                
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
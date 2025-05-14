import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pokemon_card_tracker/services/auth_service.dart';
import 'package:pokemon_card_tracker/models/pokemon_set.dart';
import 'package:pokemon_card_tracker/models/pokemon_card.dart';
import 'package:pokemon_card_tracker/utils/constants.dart';
import 'package:pokemon_card_tracker/providers/collection_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final collectionProvider = context.watch<CollectionProvider>();
    final sets = PokemonSet.getMockSets();
    
    return Scaffold(
      backgroundColor: const Color(0xFF2364AA), // Pokemon blue background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true, // Center the logo
        toolbarHeight: 140, // Increase AppBar height to accommodate larger image
        title: Image.asset(
          'logo.png',
          height: 120,
          fit: BoxFit.contain,
        ),
        automaticallyImplyLeading: false, // Remove back button if present
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              authService.logout();
              context.go('/');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title section
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
            child: Column(
              children: [
                Text(
                  'DECKS',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Container(
                    height: 4,
                    width: MediaQuery.of(context).size.width * 0.5, // 50% of screen width
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(2), // Rounded edges (2px radius)
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Sets grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20), // Added top padding
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Increased to 4 per row (makes each one narrower)
                  crossAxisSpacing: 15, // Reduced spacing
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.9, // Width to height ratio
                ),
                itemCount: sets.length,
                itemBuilder: (context, index) {
                  final set = sets[index];
                  
                  // Get actual collection progress from provider
                  final collectedCount = collectionProvider.getCollectionCount(set.id);
                  final progress = set.totalCards > 0 ? 
                      collectedCount / set.totalCards : 0.0;
                  
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go('/set/${set.id}'),
                        splashColor: Colors.blue.withOpacity(0.3),
                        highlightColor: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        child: Card(
                          elevation: 2,
                          margin: EdgeInsets.zero, // Remove default Card margin
                          color: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Set logo
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(20), // Reduced padding even more
                                  child: Image.network(
                                    set.imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 24, // Smaller icon
                                          color: Colors.grey[600],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              
                              // Progress indicator
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20), // Reduced padding
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(8),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Progress bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4), // Smaller radius
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 4, // Thinner progress bar
                                        backgroundColor: Colors.grey[400],
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.primaryBlue, // Use consistent color
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 2), // Minimal spacing
                                    // Progress text
                                    Text(
                                      '$collectedCount/${set.totalCards}',
                                      style: TextStyle(
                                        fontSize: 14, // Smaller font
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
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
    
    // Get the total collection count
    final totalCollectionCount = collectionProvider.getTotalCollectionCount();
    
    return Scaffold(
      backgroundColor: const Color(0xFF2364AA), // Pokemon blue background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true, // Center the logo
        toolbarHeight: 140, // Increase AppBar height to accommodate larger image
        title: Column(  // Wrap logo and text in a Column
          children: [
            Image.asset(
              'logo.png',
              height: 100,  // Slightly reduced height to make room for text
              fit: BoxFit.contain,
            ),
            const Text(
              'CARD TRACKER',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false, // Remove back button if present
        actions: [
          Padding(  // Added padding to position the logout button in the top right
            padding: const EdgeInsets.only(top:0, right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                authService.logout();
                context.go('/');
              },
            ),
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
                  
                  // Special handling for "My Collection" 
                  final bool isMyCollection = set.id == 'my_collection';
                  
                  // Get collection progress
                  final collectedCount = isMyCollection 
                      ? totalCollectionCount
                      : collectionProvider.getCollectionCount(set.id);
                  
                  final progress = set.totalCards > 0 
                      ? collectedCount / set.totalCards 
                      : (isMyCollection && totalCollectionCount > 0) ? 1.0 : 0.0;
                  
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (isMyCollection) {
                            // Navigate to the My Collection screen
                            context.go('/my-collection');
                          } else {
                            // Navigate to regular set detail
                            context.go('/set/${set.id}');
                          }
                        },
                        splashColor: Colors.blue.withOpacity(0.3),
                        highlightColor: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        child: Card(
                          elevation: 2,
                          margin: EdgeInsets.zero, // Remove default Card margin
                          color: isMyCollection ? Colors.amber[100] : Colors.grey[200], // Highlight My Collection
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: isMyCollection 
                              ? BorderSide(color: Colors.amber, width: 2) 
                              : BorderSide.none,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Set logo
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(20), // Reduced padding
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.network(
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
                                      if (isMyCollection)
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.amber,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '$totalCollectionCount',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Set name
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Text(
                                  set.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isMyCollection ? Colors.amber[800] : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              
                              // Progress indicator
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Reduced padding
                                decoration: BoxDecoration(
                                  color: isMyCollection ? Colors.amber[200] : Colors.grey[300],
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
                                          isMyCollection ? Colors.amber[800]! : AppColors.primaryBlue, // Use consistent color
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 2), // Minimal spacing
                                    // Progress text
                                    Text(
                                      isMyCollection 
                                          ? '$totalCollectionCount total'
                                          : '$collectedCount/${set.totalCards}',
                                      style: TextStyle(
                                        fontSize: 12, // Smaller font
                                        fontWeight: FontWeight.bold,
                                        color: isMyCollection ? Colors.amber[800] : Colors.black87,
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
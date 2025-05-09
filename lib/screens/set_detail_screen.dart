import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:pokemon_card_tracker/models/pokemon_card.dart';
import 'package:pokemon_card_tracker/models/pokemon_set.dart';
import 'package:pokemon_card_tracker/utils/constants.dart';

class SetDetailScreen extends StatefulWidget {
  final String setId;

  const SetDetailScreen({
    super.key,
    required this.setId,
  });

  @override
  State<SetDetailScreen> createState() => _SetDetailScreenState();
}

class _SetDetailScreenState extends State<SetDetailScreen> {
  late PokemonSet pokemonSet;
  List<PokemonCard> cards = [];
  bool isLoading = true;
  String searchQuery = '';
  List<String> collectedCards = []; // Track collected cards
  bool showOnlyCollected = false;

  @override
  void initState() {
    super.initState();
    loadSetData();
  }

  void loadSetData() {
    // Simulate loading delay
    Future.delayed(const Duration(seconds: 1), () {
      // Find the set from mock data
      final sets = PokemonSet.getMockSets();
      pokemonSet = sets.firstWhere((set) => set.id == widget.setId);
      
      // Load mock card data for this set
      cards = PokemonCard.getMockCardsForSet(widget.setId);
      
      setState(() {
        isLoading = false;
      });
    });
  }

  List<PokemonCard> get filteredCards {
    var filtered = cards;
    
    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((card) {
        return card.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               card.number.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    // Apply collection filter
    if (showOnlyCollected) {
      filtered = filtered.where((card) => collectedCards.contains(card.id)).toList();
    }
    
    return filtered;
  }

  void toggleCardCollection(String cardId) {
    setState(() {
      if (collectedCards.contains(cardId)) {
        collectedCards.remove(cardId);
      } else {
        collectedCards.add(cardId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final filteredCardList = filteredCards;
    final collectedCount = cards.where((card) => collectedCards.contains(card.id)).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(pokemonSet.name),
        actions: [
          IconButton(
            icon: Icon(
              showOnlyCollected ? Icons.visibility : Icons.visibility_off,
              color: showOnlyCollected ? AppColors.primaryBlue : null,
            ),
            onPressed: () {
              setState(() {
                showOnlyCollected = !showOnlyCollected;
              });
            },
            tooltip: showOnlyCollected ? 'Show all cards' : 'Show collected only',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Stats Bar
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search cards...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                SizedBox(height: 12),
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Collected: $collectedCount/${cards.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    Text(
                      '${((collectedCount / cards.length) * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Cards Grid
          Expanded(
            child: filteredCardList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          showOnlyCollected 
                              ? 'No collected cards found'
                              : 'No cards found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(120),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Increased from 2 to 3 cards per row
                      crossAxisSpacing: 80,
                      mainAxisSpacing: 80,
                      childAspectRatio: 0.72, // Made slightly taller aspect ratio
                    ),
                    itemCount: filteredCardList.length,
                    itemBuilder: (context, index) {
                      final card = filteredCardList[index];
                      final isCollected = collectedCards.contains(card.id);
                      
                      return GestureDetector(
                        onTap: () => toggleCardCollection(card.id),
                        child: Stack(
                          children: [
                            // Card Container
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    // Card Image
                                    Positioned.fill(
                                      child: CachedNetworkImage(
                                        imageUrl: card.imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey[300],
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.grey[300],
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // Overlay for collected status
                                    if (isCollected)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.7),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                              size: 48,
                                            ),
                                          ),
                                        ),
                                      ),
                                    
                                    // Card Info Overlay
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.8),
                                              Colors.transparent,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.vertical(
                                            bottom: Radius.circular(12),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              card.name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '#${card.number}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                                Text(
                                                  card.rarity,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      
      // Floating Action Button for Collection Summary
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCollectionSummary(context);
        },
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.analytics),
        label: Text('Summary'),
      ),
    );
  }

  void _showCollectionSummary(BuildContext context) {
    final collectedByRarity = <String, int>{};
    final collectedByType = <String, int>{};
    
    for (final card in cards) {
      if (collectedCards.contains(card.id)) {
        collectedByRarity[card.rarity] = (collectedByRarity[card.rarity] ?? 0) + 1;
        collectedByType[card.type] = (collectedByType[card.type] ?? 0) + 1;
      }
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Collection Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              
              Text(
                'By Rarity:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              ...collectedByRarity.entries.map((entry) => Padding(
                padding: EdgeInsets.only(left: 16, bottom: 4),
                child: Text('${entry.key}: ${entry.value}'),
              )),
              
              SizedBox(height: 16),
              Text(
                'By Type:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              ...collectedByType.entries.map((entry) => Padding(
                padding: EdgeInsets.only(left: 16, bottom: 4),
                child: Text('${entry.key}: ${entry.value}'),
              )),
              
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
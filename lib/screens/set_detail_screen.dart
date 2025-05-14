import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:pokemon_card_tracker/models/pokemon_card.dart';
import 'package:pokemon_card_tracker/models/pokemon_set.dart';
import 'package:pokemon_card_tracker/utils/constants.dart';
import 'package:pokemon_card_tracker/screens/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_card_tracker/providers/collection_provider.dart'; // Import the provider

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
  bool showOnlyCollected = false;
  bool _showOnlyUnowned = false; // Track if showing only unowned cards
  bool _quickCollectMode = false; // Track if quick collect mode is active

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
    final collectionProvider = Provider.of<CollectionProvider>(context, listen: false);
    
    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((card) {
        return card.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               card.number.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    // Apply collection filter
    if (showOnlyCollected) {
      filtered = filtered.where((card) => 
        collectionProvider.isCardCollected(widget.setId, card.id)
      ).toList();
    }
    
    // For the "show only unowned" filter
    if (_showOnlyUnowned) {
      filtered = filtered.where((card) => 
        !collectionProvider.isCardCollected(widget.setId, card.id)
      ).toList();
    }
    
    return filtered;
  }

  // Helper method to convert rarity to numeric value for sorting
  int _getRarityValue(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return 1;
      case 'uncommon':
        return 2;
      case 'rare':
        return 3;
      case 'double rare':
        return 4;
      case 'ultra rare':
        return 5;
      case 'ace spec rare':
        return 6;
      case 'illustration rare':
        return 7;
      case 'special illustration rare':
        return 8;
      case 'hyper rare':
        return 9;
      case 'promo':
        return 10;
      default:
        return 0;
    }
  }

  // Show card detail with collection status from provider
  void showCardDetail(PokemonCard card) {
    final collectionProvider = Provider.of<CollectionProvider>(context, listen: false);
    final isCollected = collectionProvider.isCardCollected(widget.setId, card.id);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the modal to take up more space
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85, // Start with 85% of screen height
          minChildSize: 0.5, // Minimum 50% when dragged down
          maxChildSize: 0.95, // Maximum 95% when dragged up
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 5),
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  
                  // Card image (larger)
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Enlarged card image
                          Center(
                            child: Hero(
                              tag: 'card-${card.id}',
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: CachedNetworkImage(
                                  imageUrl: card.imageUrl,
                                  height: MediaQuery.of(context).size.height * 0.45,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          
                          // Card details
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: Offset(0, -4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Card name with rarity
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        card.name,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getRarityColor(card.rarity),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        card.rarity,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '#${card.number}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 20),
                                
                                // Card details in grid format
                                _buildDetailRow('Set', pokemonSet.name),
                                _buildDetailRow('Series', pokemonSet.series),
                                
                                
                                SizedBox(height: 30),
                                
                                // Collection button - using provider
                                SizedBox(
                                  width: double.infinity,
                                  child: Consumer<CollectionProvider>(
                                    builder: (context, provider, child) {
                                      final isCollected = provider.isCardCollected(widget.setId, card.id);
                                      return ElevatedButton(
                                        onPressed: () {
                                          provider.toggleCardCollection(widget.setId, card.id);
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(vertical: 16),
                                          backgroundColor: isCollected 
                                              ? Colors.grey[300] 
                                              : AppColors.primaryBlue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          isCollected ? 'Remove from Collection' : 'Add to Collection',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isCollected ? Colors.black : Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
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
        );
      },
    );
  }
  
  // Helper method to build detail rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label + ':',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to get color based on rarity
  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.grey[700]!;
      case 'uncommon':
        return Colors.green[700]!;
      case 'rare':
        return Colors.blue[700]!;
      case 'double rare':
        return Colors.blue[900]!;  // Darker blue for double rare
      case 'ultra rare':
        return Colors.purple[700]!;
      case 'ace spec rare':
        return Colors.pink[400]!;
      case 'illustration rare':
        return Colors.yellow[400]!;  // Pink for illustration rare
      case 'special illustration rare':
        return Colors.pink[700]!;  // Darker pink for special illustration rare
      case 'hyper rare':
        return Colors.amber[800]!; // Gold/amber for hyper rare
      case 'promo':
        return Colors.black;
      default:
        return Colors.grey[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF2364AA), // Pokemon blue background
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return Consumer<CollectionProvider>(
      builder: (context, collectionProvider, child) {
        final filteredCardList = filteredCards;
        final collectedCount = collectionProvider.getCollectionCount(widget.setId);

        return Scaffold(
          backgroundColor: const Color(0xFF2364AA), // Pokemon blue background
          appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  // Remove centerTitle to allow title to align left
  centerTitle: false,
  toolbarHeight: 80,
  leadingWidth: 40, // Reduce leading width to bring title closer
  // Add back button to the left
  leading: IconButton(
    icon: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(4),
      child: Icon(
        Icons.arrow_back,
        color: AppColors.primaryBlue,
        size: 20,
      ),
    ),
    onPressed: () {
      // Navigate to home using GoRouter
      context.go('/home');
    },
  ),
  // Custom title with set logo and name
  title: Row(
    children: [
      // Set logo
      Container(
        height: 80,
        width: 160,
        margin: EdgeInsets.only(right: 12),
        
        padding: EdgeInsets.all(4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CachedNetworkImage(
            imageUrl: pokemonSet.imageUrl,
            fit: BoxFit.contain,
            
          ),
        ),
      ),
      
    ],
  ),
  automaticallyImplyLeading: false, // Don't use default back button
),
          body: Column(
            children: [
              // Search bar, filter button, quick collect button, and collection progress in one row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Search Field (left aligned)
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3, // 30% of screen width
                      height: 28,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // Search icon
                          Icon(
                            Icons.search,
                            color: Colors.grey[600],
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          // Search text
                          Expanded(
                            child: Container(
                              height: 28,
                              alignment: Alignment.center,
                              child: TextFormField(
                                decoration: InputDecoration.collapsed(
                                  hintText: 'Search cards...',
                                  hintStyle: TextStyle(fontSize: 12),
                                ),
                                style: TextStyle(fontSize: 12),
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(width: 12),
                    
                    // Filter Button with Popup Menu
                    Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.filter_list,
                          color: Colors.grey[600],
                          size: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        offset: const Offset(0, 30),
                        onSelected: (value) {
                          setState(() {
                            switch (value) {
                              case 'name_asc':
                                cards.sort((a, b) => a.name.compareTo(b.name));
                                break;
                              case 'name_desc':
                                cards.sort((a, b) => b.name.compareTo(a.name));
                                break;
                              case 'rarity_asc':
                                cards.sort((a, b) => _getRarityValue(a.rarity).compareTo(_getRarityValue(b.rarity)));
                                break;
                              case 'rarity_desc':
                                cards.sort((a, b) => _getRarityValue(b.rarity).compareTo(_getRarityValue(a.rarity)));
                                break;
                              case 'number_asc':
                                cards.sort((a, b) => a.number.compareTo(b.number));
                                break;
                              case 'show_owned':
                                _showOnlyUnowned = false;
                                showOnlyCollected = true;
                                break;
                              case 'show_unowned':
                                showOnlyCollected = false;
                                _showOnlyUnowned = true;
                                break;
                              case 'show_all':
                                _showOnlyUnowned = false;
                                showOnlyCollected = false;
                                break;
                            }
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem<String>(
                            value: 'name_asc',
                            child: Row(
                              children: [
                                Icon(Icons.sort_by_alpha, size: 16),
                                SizedBox(width: 8),
                                Text('Sort by Name (A-Z)'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'name_desc',
                            child: Row(
                              children: [
                                Icon(Icons.sort_by_alpha, size: 16),
                                SizedBox(width: 8),
                                Text('Sort by Name (Z-A)'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'rarity_asc',
                            child: Row(
                              children: [
                                Icon(Icons.star, size: 16),
                                SizedBox(width: 8),
                                Text('Sort by Rarity (Low-High)'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'rarity_desc',
                            child: Row(
                              children: [
                                Icon(Icons.star, size: 16),
                                SizedBox(width: 8),
                                Text('Sort by Rarity (High-Low)'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'number_asc',
                            child: Row(
                              children: [
                                Icon(Icons.numbers, size: 16),
                                SizedBox(width: 8),
                                Text('Sort by Card Number'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'show_owned',
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, size: 16),
                                SizedBox(width: 8),
                                Text('Show Only Owned Cards'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'show_unowned',
                            child: Row(
                              children: [
                                Icon(Icons.radio_button_unchecked, size: 16),
                                SizedBox(width: 8),
                                Text('Show Only Unowned Cards'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'show_all',
                            child: Row(
                              children: [
                                Icon(Icons.grid_view, size: 16),
                                SizedBox(width: 8),
                                Text('Show All Cards'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 12),
                    
                    // Quick Collect Button
                    Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        color: _quickCollectMode ? AppColors.primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _quickCollectMode = !_quickCollectMode;
                            });
                          },
                          child: Icon(
                            Icons.add_circle_outline,
                            color: _quickCollectMode ? Colors.white : Colors.grey[600],
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    
                    // Spacer to push progress bar to the right
                    Spacer(),
                    
                    // Collection Progress Bar (right aligned and smaller)
                    Container(
                      height: 32,
                      width: MediaQuery.of(context).size.width * 0.4, // 40% of screen width
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: cards.isEmpty ? 0 : collectedCount / cards.length,
                              minHeight: 4, // Smaller progress bar height
                              backgroundColor: Colors.grey[500],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryBlue,
                              ),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '$collectedCount/${cards.length}',
                            style: TextStyle(
                              fontSize: 10, // Smaller font size
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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
                                  : (_showOnlyUnowned ? 'No uncollected cards found' : 'No cards found'),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6, // Keep the same number of cards per row
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.72, // Keep the same aspect ratio
                        ),
                        itemCount: filteredCardList.length,
                        itemBuilder: (context, index) {
                          final card = filteredCardList[index];
                          final isCollected = collectionProvider.isCardCollected(widget.setId, card.id);
                          
                          return GestureDetector(
                            onTap: () {
                              if (_quickCollectMode) {
                                // Toggle collection status via provider
                                collectionProvider.toggleCardCollection(widget.setId, card.id);
                              } else {
                                // Normal mode - show card detail
                                showCardDetail(card);
                              }
                            },
                            child: Hero(
                              tag: 'card-${card.id}',
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
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
                                        child: ColorFiltered(
                                          // Apply grayscale filter if not collected
                                          colorFilter: isCollected 
                                            ? ColorFilter.mode(Colors.transparent, BlendMode.srcOver)
                                            : ColorFilter.matrix([
                                                0.2126, 0.7152, 0.0722, 0, 0,
                                                0.2126, 0.7152, 0.0722, 0, 0,
                                                0.2126, 0.7152, 0.0722, 0, 0,
                                                0, 0, 0, 1, 0,
                                              ]),
                                          child: CachedNetworkImage(
                                            imageUrl: card.imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              color: Colors.grey[200],
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    AppColors.primaryBlue,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.image_not_supported,
                                                size: 36,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Collection indicator
                                      if (isCollected)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryBlue,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                          ),
                                        ),
                                      // Quick collect mode indicator
                                      if (_quickCollectMode)
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(vertical: 4),
                                            color: AppColors.successGreen.withOpacity(0.9),
                                            child: Text(
                                              isCollected ? 'Tap to Remove' : 'Tap to Collect',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
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
            ],
          ),
          
          
        );
      }
    );
  }
}
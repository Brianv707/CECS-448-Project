import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_card_tracker/models/pokemon_card.dart';
import 'package:pokemon_card_tracker/providers/collection_provider.dart';
import 'package:pokemon_card_tracker/utils/constants.dart';

class MyCollectionScreen extends StatefulWidget {
  const MyCollectionScreen({Key? key}) : super(key: key);

  @override
  State<MyCollectionScreen> createState() => _MyCollectionScreenState();
}

class _MyCollectionScreenState extends State<MyCollectionScreen> {
  List<PokemonCard> cards = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedSortOption = 'name_asc'; // Default sort option
  String? filterBySet; // If not null, filter cards by this set ID

  @override
  void initState() {
    super.initState();
    loadCards();
  }

  void loadCards() {
    // Simulate loading delay (in real app, you might load from a database)
    Future.delayed(const Duration(milliseconds: 300), () {
      final collectionProvider = Provider.of<CollectionProvider>(context, listen: false);
      setState(() {
        cards = collectionProvider.getAllCollectedCards();
        isLoading = false;
        
        // Initial sort by name
        _sortCards();
      });
    });
  }

  void _sortCards() {
    switch (selectedSortOption) {
      case 'name_asc':
        cards.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        cards.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'number_asc':
        cards.sort((a, b) => a.number.compareTo(b.number));
        break;
      case 'set_asc':
        cards.sort((a, b) => a.setId.compareTo(b.setId));
        break;
      case 'rarity_asc':
        cards.sort((a, b) => _getRarityValue(a.rarity).compareTo(_getRarityValue(b.rarity)));
        break;
      case 'rarity_desc':
        cards.sort((a, b) => _getRarityValue(b.rarity).compareTo(_getRarityValue(a.rarity)));
        break;
    }
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
      case 'illustration rare':
        return 6;
      case 'special illustration rare':
        return 7;
      case 'hyper rare':
        return 8;
      case 'promo':
        return 9;
      default:
        return 0;
    }
  }

  List<PokemonCard> get filteredCards {
    List<PokemonCard> filtered = List.from(cards);
    
    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((card) {
        return card.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               card.number.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    // Apply set filter
    if (filterBySet != null) {
      filtered = filtered.where((card) => card.setId == filterBySet).toList();
    }
    
    return filtered;
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
      case 'illustration rare':
        return Colors.pink[400]!;  // Pink for illustration rare
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

  // Show card detail dialog
  void showCardDetail(PokemonCard card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
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
                                _buildDetailRow('Set', card.setId),
                                
                                
                                SizedBox(height: 30),
                                
                                // View in Set button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      // Navigate to set detail screen
                                      context.go('/set/${card.setId}');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      backgroundColor: AppColors.primaryBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'View in Set',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF2364AA),
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

    final filteredCardList = filteredCards;

    return Scaffold(
      backgroundColor: const Color(0xFF2364AA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        title: const Text(
          'My Collection',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
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
            context.go('/home');
          },
        ),
      ),
      body: Column(
        children: [
          // Search bar, filter button, and filter info in one row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Search Field (left aligned) - UPDATED to match SetDetailScreen
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
                
                // Filter Button with Popup Menu - UPDATED to match SetDetailScreen
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
                        selectedSortOption = value;
                        _sortCards();
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
                        value: 'set_asc',
                        child: Row(
                          children: [
                            Icon(Icons.collections, size: 16),
                            SizedBox(width: 8),
                            Text('Sort by Set'),
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
                    ],
                  ),
                ),
                
                SizedBox(width: 12),
                
                // Set Filter Button - UPDATED to match SetDetailScreen
                Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    color: filterBySet != null ? AppColors.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: PopupMenuButton<String?>(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.filter_alt,
                      color: filterBySet != null ? Colors.white : Colors.grey[600],
                      size: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    offset: const Offset(0, 30),
                    onSelected: (value) {
                      setState(() {
                        filterBySet = value;
                      });
                    },
                    itemBuilder: (context) {
                      // Get unique set IDs from collected cards
                      final setIds = cards.map((c) => c.setId).toSet().toList();
                      
                      // Create menu items
                      List<PopupMenuItem<String?>> items = [
                        
                      ];
                      
                      // Add all the sets
                      items.addAll(
                        setIds.map((setId) => PopupMenuItem<String?>(
                          value: setId,
                          child: Row(
                            children: [
                              Icon(Icons.folder, size: 16),
                              SizedBox(width: 8),
                              Text(setId),
                            ],
                          ),
                        )).toList()
                      );
                      
                      return items;
                    },
                  ),
                ),

                // Spacer to push card count to the right
                Spacer(),
                
                // Collection count indicator
                Container(
                  height: 28,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${filteredCardList.length} cards',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          // Filter info if a set filter is active
          if (filterBySet != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Filtered by: ${filterBySet}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        filterBySet = null;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.clear,
                        color: Colors.white,
                        size: 12,
                      ),
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
                          'No cards found in your collection',
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
                      crossAxisCount: 6,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: filteredCardList.length,
                    itemBuilder: (context, index) {
                      final card = filteredCardList[index];
                      
                      return GestureDetector(
                        onTap: () => showCardDetail(card),
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
                                  
                                  // Set badge (top-left corner)
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        card.setId,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
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
      // Add floating action button for sorting/filtering options similar to SetDetailScreen
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSortingFilteringOptions(context);
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.tune),
      ),
    );
  }
  
  // Show more detailed sorting and filtering options
  void _showSortingFilteringOptions(BuildContext context) {
    // Get unique set IDs for filtering options
    final setIds = cards.map((c) => c.setId).toSet().toList();
    setIds.sort(); // Sort alphabetically
    
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
                'Sort & Filter',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              
              Text(
                'Sort by:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildSortChip('Name (A-Z)', 'name_asc'),
                  _buildSortChip('Name (Z-A)', 'name_desc'),
                  _buildSortChip('Number', 'number_asc'),
                  _buildSortChip('Set', 'set_asc'),
                  _buildSortChip('Rarity (Low-High)', 'rarity_asc'),
                  _buildSortChip('Rarity (High-Low)', 'rarity_desc'),
                ],
              ),
              
              SizedBox(height: 16),
              Text(
                'Filter by Set:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              
              Container(
                height: 120, // Fixed height for the set filter section
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: Text('All Sets'),
                        selected: filterBySet == null,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              filterBySet = null;
                              Navigator.pop(context);
                            });
                          }
                        },
                      ),
                      ...setIds.map((setId) => FilterChip(
                        label: Text(setId),
                        selected: filterBySet == setId,
                        onSelected: (selected) {
                          setState(() {
                            filterBySet = selected ? setId : null;
                            Navigator.pop(context);
                          });
                        },
                      )).toList(),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Helper method to build sort option chips
  Widget _buildSortChip(String label, String sortValue) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedSortOption == sortValue,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            selectedSortOption = sortValue;
            _sortCards();
            Navigator.pop(context);
          });
        }
      },
    );
  }
}
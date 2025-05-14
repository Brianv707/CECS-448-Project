// collection_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CollectionProvider extends ChangeNotifier {
  Map<String, List<String>> _collectionsBySet = {};
  bool _isLoaded = false;

  CollectionProvider() {
    _loadCollections();
  }

  // Get collected cards for a specific set
  List<String> getCollectedCards(String setId) {
    _ensureLoaded();
    return _collectionsBySet[setId] ?? [];
  }

  // Check if a card is collected
  bool isCardCollected(String setId, String cardId) {
    _ensureLoaded();
    final setCollection = _collectionsBySet[setId] ?? [];
    return setCollection.contains(cardId);
  }

  // Toggle card collection status
  void toggleCardCollection(String setId, String cardId) {
    _ensureLoaded();
    
    // Get the current collection for the set or create a new one
    final setCollection = List<String>.from(_collectionsBySet[setId] ?? []);
    
    // Toggle the card's collection status
    if (setCollection.contains(cardId)) {
      setCollection.remove(cardId);
    } else {
      setCollection.add(cardId);
    }
    
    // Update the collection
    _collectionsBySet[setId] = setCollection;
    
    // Save changes to persistent storage
    _saveCollections();
    
    // Notify listeners
    notifyListeners();
  }

  // Get collection count for a specific set
  int getCollectionCount(String setId) {
    _ensureLoaded();
    return _collectionsBySet[setId]?.length ?? 0;
  }

  // Get collection completion percentage for a set
  double getCompletionPercentage(String setId, int totalCards) {
    _ensureLoaded();
    if (totalCards == 0) return 0.0;
    return (getCollectionCount(setId) / totalCards).clamp(0.0, 1.0);
  }

  // Ensure data is loaded before access
  void _ensureLoaded() {
    if (!_isLoaded) {
      // If data isn't loaded yet, load synchronously (should be rare)
      _loadCollectionsSync();
    }
  }

  // Load collections from persistent storage
  Future<void> _loadCollections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? collectionsJson = prefs.getString('collections');
      
      if (collectionsJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(collectionsJson);
        
        // Convert the JSON map to our internal structure
        _collectionsBySet = {};
        decoded.forEach((setId, cards) {
          _collectionsBySet[setId] = List<String>.from(cards);
        });
      }
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      print('Error loading collections: $e');
    }
  }

  // Synchronous version for emergency use
  void _loadCollectionsSync() {
    try {
      final prefs = SharedPreferences.getInstance().then((prefs) {
        final String? collectionsJson = prefs.getString('collections');
        
        if (collectionsJson != null) {
          final Map<String, dynamic> decoded = jsonDecode(collectionsJson);
          
          // Convert the JSON map to our internal structure
          _collectionsBySet = {};
          decoded.forEach((setId, cards) {
            _collectionsBySet[setId] = List<String>.from(cards);
          });
        }
        
        _isLoaded = true;
        notifyListeners();
      });
    } catch (e) {
      print('Error loading collections sync: $e');
    }
  }

  // Save collections to persistent storage
  Future<void> _saveCollections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert our internal structure to a JSON-serializable map
      final Map<String, dynamic> collectionsMap = {};
      _collectionsBySet.forEach((setId, cards) {
        collectionsMap[setId] = cards;
      });
      
      // Save to shared preferences
      await prefs.setString('collections', jsonEncode(collectionsMap));
    } catch (e) {
      print('Error saving collections: $e');
    }
  }

  // Clear all collections (useful for testing or reset functionality)
  Future<void> clearAllCollections() async {
    _collectionsBySet = {};
    await _saveCollections();
    notifyListeners();
  }
}
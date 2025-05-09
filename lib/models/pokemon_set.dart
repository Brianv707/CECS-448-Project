class PokemonSet {
  final String id;
  final String name;
  final String series;
  final String imageUrl;
  final int totalCards;
  final DateTime releaseDate;
  
  PokemonSet({
    required this.id,
    required this.name,
    required this.series,
    required this.imageUrl,
    required this.totalCards,
    required this.releaseDate,
  });
  
  // Mock data for demonstration
  static List<PokemonSet> getMockSets() {
    return [
      PokemonSet(
        id: 'base1',
        name: 'Base Set',
        series: 'Base',
        imageUrl: 'https://images.pokemontcg.io/base1/logo.png',
        totalCards: 102,
        releaseDate: DateTime(1999, 1, 9),
      ),
      PokemonSet(
        id: 'base2',
        name: 'Jungle',
        series: 'Base',
        imageUrl: 'https://images.pokemontcg.io/base2/logo.png',
        totalCards: 64,
        releaseDate: DateTime(1999, 6, 16),
      ),
      PokemonSet(
        id: 'base3',
        name: 'Fossil',
        series: 'Base',
        imageUrl: 'https://images.pokemontcg.io/base3/logo.png',
        totalCards: 62,
        releaseDate: DateTime(1999, 10, 10),
      ),
      // Add more sets as needed
    ];
  }
}
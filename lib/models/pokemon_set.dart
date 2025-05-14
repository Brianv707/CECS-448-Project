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
        name: 'Shrouded Fable',
        series: 'Scarlet/Violet',
        imageUrl: 'https://static.wixstatic.com/media/7aff29_409464b58c1341918aad57a779d7cfa5~mv2.png/v1/fill/w_1830,h_860,al_c/7aff29_409464b58c1341918aad57a779d7cfa5~mv2.png',
        totalCards: 99,
        releaseDate: DateTime(2024, 8, 2),
      ),
      PokemonSet(
        id: 'base2',
        name: 'McDonalds Promo',
        series: 'Promo',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/International_Pok%C3%A9mon_logo.svg/1024px-International_Pok%C3%A9mon_logo.svg.png',
        totalCards: 15,
        releaseDate: DateTime(2025, 1, 16),
      ),
      PokemonSet(
        id: 'base3',
        name: 'Stellar Crown',
        series: 'Scarlet/Violet',
        imageUrl: 'https://s3.pokeos.com/pokeos-uploads/tcg/eng/359/src/Expansion_SV7_EN.png',
        totalCards: 175,
        releaseDate: DateTime(1999, 10, 10),
      ),
    ];
  }
}
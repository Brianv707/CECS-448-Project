class PokemonCard {
  final String id;
  final String name;
  final String number;
  final String imageUrl;
  final String rarity;
  final String type;
  final String setId;
  
  PokemonCard({
    required this.id,
    required this.name,
    required this.number,
    required this.imageUrl,
    required this.rarity,
    required this.type,
    required this.setId,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'imageUrl': imageUrl,
      'rarity': rarity,
      'type': type,
      'setId': setId,
    };
  }
  
  factory PokemonCard.fromJson(Map<String, dynamic> json) {
    return PokemonCard(
      id: json['id'],
      name: json['name'],
      number: json['number'],
      imageUrl: json['imageUrl'],
      rarity: json['rarity'],
      type: json['type'],
      setId: json['setId'],
    );
  }
  
  // Mock data generator for different sets
  static List<PokemonCard> getMockCardsForSet(String setId) {
    // For demo purposes, generate different cards based on set
    switch (setId) {
      case 'base1':
        return _getBaseSetCards();
      case 'base2':
        return _getJungleCards();
      case 'base3':
        return _getFossilCards();
      default:
        return [];
    }
  }
  
  static List<PokemonCard> _getBaseSetCards() {
    return [
      PokemonCard(
        id: 'base1-1',
        name: 'Charizard',
        number: '4',
        imageUrl: 'https://images.pokemontcg.io/base1/4_hires.png',
        rarity: 'Rare Holo',
        type: 'Fire',
        setId: 'base1',
      ),
      PokemonCard(
        id: 'base1-2',
        name: 'Blastoise',
        number: '2',
        imageUrl: 'https://images.pokemontcg.io/base1/2_hires.png',
        rarity: 'Rare Holo',
        type: 'Water',
        setId: 'base1',
      ),
      PokemonCard(
        id: 'base1-3',
        name: 'Venusaur',
        number: '15',
        imageUrl: 'https://images.pokemontcg.io/base1/15_hires.png',
        rarity: 'Rare Holo',
        type: 'Grass',
        setId: 'base1',
      ),
      PokemonCard(
        id: 'base1-4',
        name: 'Pikachu',
        number: '58',
        imageUrl: 'https://images.pokemontcg.io/base1/58_hires.png',
        rarity: 'Common',
        type: 'Electric',
        setId: 'base1',
      ),
      PokemonCard(
        id: 'base1-5',
        name: 'Mewtwo',
        number: '10',
        imageUrl: 'https://images.pokemontcg.io/base1/10_hires.png',
        rarity: 'Rare Holo',
        type: 'Psychic',
        setId: 'base1',
      ),
      PokemonCard(
        id: 'base1-6',
        name: 'Alakazam',
        number: '1',
        imageUrl: 'https://images.pokemontcg.io/base1/1_hires.png',
        rarity: 'Rare Holo',
        type: 'Psychic',
        setId: 'base1',
      ),
      PokemonCard(
        id: 'base1-7',
        name: 'Machamp',
        number: '8',
        imageUrl: 'https://images.pokemontcg.io/base1/8_hires.png',
        rarity: 'Rare Holo',
        type: 'Fighting',
        setId: 'base1',
      ),
      PokemonCard(
        id: 'base1-8',
        name: 'Poliwrath',
        number: '13',
        imageUrl: 'https://images.pokemontcg.io/base1/13_hires.png',
        rarity: 'Rare Holo',
        type: 'Water',
        setId: 'base1',
      ),
      PokemonCard(
        id: 'base1-9',
        name: 'Squirtle',
        number: '63',
        imageUrl: 'https://images.pokemontcg.io/base1/63_hires.png',
        rarity: 'Common',
        type: 'Water',
        setId: 'base1',
      ),
      PokemonCard(
        id: 'base1-10',
        name: 'Bulbasaur',
        number: '44',
        imageUrl: 'https://images.pokemontcg.io/base1/44_hires.png',
        rarity: 'Common',
        type: 'Grass',
        setId: 'base1',
      ),
    ];
  }
  
  static List<PokemonCard> _getJungleCards() {
    return [
      PokemonCard(
        id: 'base2-1',
        name: 'Scyther',
        number: '10',
        imageUrl: 'https://images.pokemontcg.io/base2/10_hires.png',
        rarity: 'Rare Holo',
        type: 'Grass',
        setId: 'base2',
      ),
      PokemonCard(
        id: 'base2-2',
        name: 'Pinsir',
        number: '9',
        imageUrl: 'https://images.pokemontcg.io/base2/9_hires.png',
        rarity: 'Rare Holo',
        type: 'Grass',
        setId: 'base2',
      ),
      PokemonCard(
        id: 'base2-3',
        name: 'Vaporeon',
        number: '12',
        imageUrl: 'https://images.pokemontcg.io/base2/12_hires.png',
        rarity: 'Rare Holo',
        type: 'Water',
        setId: 'base2',
      ),
      PokemonCard(
        id: 'base2-4',
        name: 'Pikachu',
        number: '60',
        imageUrl: 'https://images.pokemontcg.io/base2/60_hires.png',
        rarity: 'Common',
        type: 'Electric',
        setId: 'base2',
      ),
      PokemonCard(
        id: 'base2-5',
        name: 'Flareon',
        number: '3',
        imageUrl: 'https://images.pokemontcg.io/base2/3_hires.png',
        rarity: 'Rare Holo',
        type: 'Fire',
        setId: 'base2',
      ),
    ];
  }
  
  static List<PokemonCard> _getFossilCards() {
    return [
      PokemonCard(
        id: 'base3-1',
        name: 'Aerodactyl',
        number: '1',
        imageUrl: 'https://images.pokemontcg.io/base3/1_hires.png',
        rarity: 'Rare Holo',
        type: 'Fighting',
        setId: 'base3',
      ),
      PokemonCard(
        id: 'base3-2',
        name: 'Kabutops',
        number: '9',
        imageUrl: 'https://images.pokemontcg.io/base3/9_hires.png',
        rarity: 'Rare Holo',
        type: 'Fighting',
        setId: 'base3',
      ),
      PokemonCard(
        id: 'base3-3',
        name: 'Lapras',
        number: '10',
        imageUrl: 'https://images.pokemontcg.io/base3/10_hires.png',
        rarity: 'Rare Holo',
        type: 'Water',
        setId: 'base3',
      ),
      PokemonCard(
        id: 'base3-4',
        name: 'Kabuto',
        number: '50',
        imageUrl: 'https://images.pokemontcg.io/base3/50_hires.png',
        rarity: 'Common',
        type: 'Fighting',
        setId: 'base3',
      ),
      PokemonCard(
        id: 'base3-5',
        name: 'Omanyte',
        number: '52',
        imageUrl: 'https://images.pokemontcg.io/base3/52_hires.png',
        rarity: 'Common',
        type: 'Water',
        setId: 'base3',
      ),
    ];
  }
}
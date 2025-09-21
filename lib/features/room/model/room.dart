class Room {
  final String id;
  final String name;
  final List<String> players;
  final int playersCount;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  Room({
    required this.id,
    required this.name,
    required this.players,
    required this.playersCount,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      players: (json['players'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      playersCount: json['players_count'] ?? 0,
      status: json['status'] ?? 'waiting',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'players': players,
      'players_count': playersCount,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

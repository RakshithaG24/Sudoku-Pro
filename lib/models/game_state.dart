/// Difficulty levels with corresponding number of cells to remove
enum Difficulty {
  easy(name: 'Easy', cellsToRemove: 35, color: 0xFF4CAF50),
  medium(name: 'Medium', cellsToRemove: 45, color: 0xFFFF9800),
  hard(name: 'Hard', cellsToRemove: 55, color: 0xFFE53935);

  final String name;
  final int cellsToRemove;
  final int color;

  const Difficulty({
    required this.name,
    required this.cellsToRemove,
    required this.color,
  });
}

/// Snapshot of the board for undo/redo history
class BoardSnapshot {
  final List<List<int>> values;
  final List<List<int?>> notes;

  BoardSnapshot({required this.values, required this.notes});

  factory BoardSnapshot.fromJson(Map<String, dynamic> json) {
    return BoardSnapshot(
      values: (json['values'] as List)
          .map((row) => (row as List).map((v) => v as int).toList())
          .toList(),
      notes: (json['notes'] as List)
          .map((row) => (row as List).map((v) => v as int?).toList())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'values': values,
        'notes': notes,
      };
}

/// Overall game status
enum GameStatus { idle, playing, paused, completed }

/// Represents a single cell in the 9x9 Sudoku grid.
class SudokuCell {
  int value;          // 0 = empty, 1-9 = filled
  bool isFixed;       // Cannot be edited by user
  bool isError;       // User entered wrong number
  bool isHighlighted; // Part of selected row/col/box
  bool isSelected;    // Currently selected cell
  int? noteValues;    // Bitmask for pencil marks (bits 1-9)

  SudokuCell({
    this.value = 0,
    this.isFixed = false,
    this.isError = false,
    this.isHighlighted = false,
    this.isSelected = false,
    this.noteValues,
  });

  /// Returns true if this cell is empty
  bool get isEmpty => value == 0;

  /// Toggle a note value (1-9)
  void toggleNote(int num) {
    noteValues ??= 0;
    noteValues = noteValues! ^ (1 << num);
  }

  /// Check if a note is set
  bool hasNote(int num) {
    if (noteValues == null) return false;
    return (noteValues! & (1 << num)) != 0;
  }

  /// List of active notes
  List<int> get notes {
    if (noteValues == null) return [];
    return List.generate(9, (i) => i + 1)
        .where((n) => hasNote(n))
        .toList();
  }

  /// Copy constructor
  SudokuCell copyWith({
    int? value,
    bool? isFixed,
    bool? isError,
    bool? isHighlighted,
    bool? isSelected,
    int? noteValues,
  }) {
    return SudokuCell(
      value: value ?? this.value,
      isFixed: isFixed ?? this.isFixed,
      isError: isError ?? this.isError,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isSelected: isSelected ?? this.isSelected,
      noteValues: noteValues ?? this.noteValues,
    );
  }
}

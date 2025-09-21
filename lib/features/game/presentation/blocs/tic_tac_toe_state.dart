import 'package:equatable/equatable.dart';

class TicTacToeState extends Equatable{
  final List<List<String>> board;
  final String currentPlayer;
  final String status;

  const TicTacToeState({
    required this.board,
    required this.currentPlayer,
    required this.status,
});

  TicTacToeState copyWith({
    List<List<String>>? board,
    String? currentPlayer,
    String? status,
}) {
    return TicTacToeState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
    );
  }

    @override
    List<Object?> get props => [board, currentPlayer, status];
}
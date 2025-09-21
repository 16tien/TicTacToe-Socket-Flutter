import 'package:equatable/equatable.dart';

abstract class TicTacToeEvent extends Equatable{
  const TicTacToeEvent();

  @override
  List<Object?> get props => [];
}

class ConnectWS extends TicTacToeEvent{}

class DisconnectWS extends TicTacToeEvent{}

class SendMove extends TicTacToeEvent{
  final int x;
  final int y;
  final String player;
  const SendMove({required this.x, required this.y, required this.player});

  @override
  List<Object?> get props => [x,y,player];
}

class ReceivedMessage extends TicTacToeEvent{
  final Map<String, dynamic> message;
  const ReceivedMessage(this.message);

  @override
  List<Object?> get props => [message];
}
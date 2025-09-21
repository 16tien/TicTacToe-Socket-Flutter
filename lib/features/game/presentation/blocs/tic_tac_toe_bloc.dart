import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xo/core/network/ws_client.dart';
import 'tic_tac_toe_event.dart';
import 'tic_tac_toe_state.dart';
import '../../data/TTTMessage.dart';

class TicTacToeBloc extends Bloc<TicTacToeEvent, TicTacToeState> {
  final WSClient ws;
  StreamSubscription? _wsSub;

  TicTacToeBloc({required this.ws})
      : super(TicTacToeState(
    board: List.generate(3, (_) => List.filled(3, '')),
    currentPlayer: 'X',
    status: 'waiting',
  )) {
    on<ConnectWS>(_onConnect);
    on<DisconnectWS>(_onDisconnect);
    on<SendMove>(_onSendMove);
    on<ReceivedMessage>(_onReceivedMessage);
  }

  void _onConnect(ConnectWS event, Emitter<TicTacToeState> emit) {
    ws.connect();

    // Listen stream từ WSClient
    _wsSub ??= ws.onMessageStream.listen((message) {
      add(ReceivedMessage(message));
    });
  }

  void _onDisconnect(DisconnectWS event, Emitter<TicTacToeState> emit) {
    _wsSub?.cancel();
    _wsSub = null;
    ws.close();
  }

  void _onSendMove(SendMove event, Emitter<TicTacToeState> emit) {
    ws.send(TTTMessage(type: 'move', data: {
      'x': event.x,
      'y': event.y,
      'player': event.player,
    }));
  }

  void _onReceivedMessage(ReceivedMessage event, Emitter<TicTacToeState> emit) {
    final message = event.message;
    final type = message['type'];
    final data = message['data'];

    if (type == 'move') {
      final boardCopy = state.board.map((row) => [...row]).toList();
      boardCopy[data['x']][data['y']] = data['player'];
      emit(state.copyWith(
          board: boardCopy,
          currentPlayer: data['player'] == 'X' ? 'O' : 'X',
          status: 'your_turn'));
    } else if (type == 'win' || type == 'draw') {
      emit(state.copyWith(status: type));
    }
  }

  @override
  Future<void> close() {
    _wsSub?.cancel();
    ws.close();
    return super.close();
  }
}
